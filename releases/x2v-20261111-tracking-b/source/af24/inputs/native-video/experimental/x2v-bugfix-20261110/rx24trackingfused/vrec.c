/* H.264 recorder. The camera's hardware encoder is driven by the stock test_venc_e2 tool, which reads
 * NV12 frames from one pipe and writes an Annex-B stream to another. This side feeds it every colour
 * frame, cuts the stream into access units and writes them to an MP4 file whose sample times come
 * from the frames' own timestamps.
 * The pipes are anonymous because camera-service may not create FIFOs; the tool opens them by path as
 * /proc/self/fd/3 and 4. Both ends of both stay open here, so the tool never sees end of input (there it
 * would re-encode stale buffers forever) and a dead tool never raises SIGPIPE in camera-service. The
 * encoder emits one access unit per frame, in order, so a clip keeps exactly as many as frames were fed;
 * throwaway frames push the last one out, then the tool is terminated. */
#define _GNU_SOURCE 1
#include "vrec.h"
#include "prr_mov.h"
#include <errno.h>
#include <fcntl.h>
#include <math.h>
#include <poll.h>
#include <pthread.h>
#include <signal.h>
#include <spawn.h>
#include <stdatomic.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/resource.h>
#include <sys/stat.h>
#include <sys/syscall.h>
#include <sys/wait.h>
#include <time.h>
#include <unistd.h>

#define VR_W 1300
#define VR_H 970
#define VR_STRIDE 1536
#define VR_SRC_BYTES (VR_STRIDE * VR_H * 3 / 2)
#define VR_FRAME (VR_W * VR_H * 3 / 2)
#define VR_SLOTS 4
#define VR_TS 256                /* fed frames whose access unit is not yet written */
#define VR_FLUSH_MAX 48
#define VR_LAG 16                /* frames the encoder may hold before it must have produced output */
#define VR_DIR "/tmp/x2v-live"
#define VR_CFG VR_DIR "/venc.json"
#define VR_TOOL "/system/bin/test_venc_e2"
#define VR_FILE "clip.partial.mp4"
#define VR_FRAME_US (1e6 / 24)
#define VR_SETTLE_NS 1000000000ull    /* the start's SSD stall ended within 0.61 s of the spawn */

extern int duss_hal_mem_get_size(void *, uint32_t *);
extern int duss_hal_mem_map(void *, void **);
extern int duss_hal_mem_unmap(void *);
extern int duss_hal_mem_sync_ext(void *, unsigned, unsigned, uint64_t);

static struct {
    _Atomic int open, in_flight, err;
    pthread_mutex_t mu, wait_mu;
    pthread_cond_t cv;
    uint8_t *slot[VR_SLOTS];
    uint64_t slot_ts[VR_SLOTS];
    _Atomic int slot_state[VR_SLOTS];   /* 0 free, 1 filling, 2 queued or feeding */
    int q[VR_SLOTS], qh, qn;
    uint64_t ts[VR_TS], ts0;
    uint32_t fed, muxed, target, keys;
    int stopping, target_set, done;
    int in_fd, out_fd;                  /* ours: input write end, output read end (non-blocking) */
    int in_keep, out_keep;              /* the tool's fd 3 and 4 */
    pid_t pid;
    int child_done;
    pthread_t feeder, reader;
    struct prr_mov mov;
    uint8_t *au;
    size_t au_len, au_cap;
    int au_slices, au_key;
    uint8_t sps[256], pps[256];
    uint32_t sps_len, pps_len;
    uint8_t avcc[600];
    _Atomic uint32_t seen, dropped, feed_ms_max;
    _Atomic uint64_t bytes;
} V = { .mu = PTHREAD_MUTEX_INITIALIZER, .wait_mu = PTHREAD_MUTEX_INITIALIZER, .cv = PTHREAD_COND_INITIALIZER,
        .in_fd = -1, .out_fd = -1, .in_keep = -1, .out_keep = -1, .pid = -1 };

static void (*filter)(uint8_t *, int, int);
void vrec_set_filter(void (*fn)(uint8_t *, int, int)) { filter = fn; }

static uint64_t now_ns(void)
{
    struct timespec t;
    clock_gettime(CLOCK_MONOTONIC, &t);
    return (uint64_t)t.tv_sec * 1000000000ull + (uint64_t)t.tv_nsec;
}
static uint64_t u64(const void *p, size_t o) { uint64_t v; memcpy(&v, (const char *)p + o, 8); return v; }

static void fail(int e)
{
    int z = 0;
    atomic_compare_exchange_strong(&V.err, &z, e ? e : EIO);
    pthread_mutex_lock(&V.mu);
    pthread_cond_broadcast(&V.cv);
    pthread_mutex_unlock(&V.mu);
}

/* ---------- colour callback ---------- */

static int copy_tight(void *frame, uint8_t *dst)
{
    void *handle = (void *)(uintptr_t)u64(frame, 0x20), *p = NULL;
    uint32_t size = 0;
    if (!handle) return EINVAL;
    int e = duss_hal_mem_get_size(handle, &size);
    if (!e && size < VR_SRC_BYTES) e = EOVERFLOW;
    if (e) return e;
    if ((e = duss_hal_mem_map(handle, &p))) return e;
    e = p ? duss_hal_mem_sync_ext(handle, 1, 0, VR_SRC_BYTES) : EFAULT;
    if (!e)
        for (int r = 0; r < VR_H * 3 / 2; r++)
            memcpy(dst + (size_t)r * VR_W, (const uint8_t *)p + (size_t)r * VR_STRIDE, VR_W);
    int u = duss_hal_mem_unmap(handle);
    return e ? e : u;
}

void vrec_colour(void *frame)
{
    atomic_fetch_add(&V.in_flight, 1);
    if (atomic_load(&V.open)) {
        atomic_fetch_add(&V.seen, 1);
        int k = -1;
        for (int i = 0; i < VR_SLOTS && k < 0; i++) {
            int z = 0;
            if (atomic_compare_exchange_strong(&V.slot_state[i], &z, 1)) k = i;
        }
        if (k < 0 || copy_tight(frame, V.slot[k])) {
            atomic_fetch_add(&V.dropped, 1);
            if (k >= 0) atomic_store(&V.slot_state[k], 0);
        } else {
            V.slot_ts[k] = u64(frame, 0x30);
            pthread_mutex_lock(&V.mu);
            atomic_store(&V.slot_state[k], 2);
            V.q[(V.qh + V.qn) % VR_SLOTS] = k;
            V.qn++;
            pthread_cond_broadcast(&V.cv);
            pthread_mutex_unlock(&V.mu);
        }
    }
    atomic_fetch_sub(&V.in_flight, 1);
}

/* ---------- encoder process ---------- */

static int child_gone(void)
{
    pthread_mutex_lock(&V.wait_mu);
    if (!V.child_done && V.pid > 0) {
        int st = 0;
        pid_t r = waitpid(V.pid, &st, WNOHANG);
        /* With SIGCHLD ignored the child is reaped by the kernel and waitpid reports ECHILD. */
        if (r == V.pid || (r < 0 && errno == ECHILD && kill(V.pid, 0) && errno == ESRCH)) V.child_done = 1;
    }
    int d = V.child_done || V.pid <= 0;
    pthread_mutex_unlock(&V.wait_mu);
    return d;
}

static int spawn_tool(void)
{
    posix_spawn_file_actions_t fa;
    posix_spawnattr_t at;
    sigset_t none, def;
    memset(&none, 0, sizeof none);
    memset(&def, 0, sizeof def);
    /* camera-service's ignored signals would survive exec; SIGKILL/SIGSTOP cannot be reset. */
    for (int s = 1; s < 32; s++)
        if (s != SIGKILL && s != SIGSTOP) sigaddset(&def, s);
    int e = posix_spawn_file_actions_init(&fa);
    if (e) return e;
    if ((e = posix_spawnattr_init(&at))) { posix_spawn_file_actions_destroy(&fa); return e; }
    e = posix_spawn_file_actions_addopen(&fa, 0, "/dev/null", O_RDONLY, 0);
    if (!e) e = posix_spawn_file_actions_addopen(&fa, 1, "/dev/null", O_WRONLY, 0);
    if (!e) e = posix_spawn_file_actions_addopen(&fa, 2, "/dev/null", O_WRONLY, 0);
    if (!e) e = posix_spawn_file_actions_adddup2(&fa, V.in_keep, 3);
    if (!e) e = posix_spawn_file_actions_adddup2(&fa, V.out_keep, 4);
    if (!e) e = posix_spawnattr_setsigmask(&at, &none);
    if (!e) e = posix_spawnattr_setsigdefault(&at, &def);
    if (!e) e = posix_spawnattr_setflags(&at, POSIX_SPAWN_SETSIGMASK | POSIX_SPAWN_SETSIGDEF | POSIX_SPAWN_USEVFORK);
    char *argv[] = { (char *)VR_TOOL, (char *)VR_CFG, NULL };
    char *envp[] = { (char *)"PATH=/system/bin", NULL };
    if (!e) e = posix_spawn(&V.pid, VR_TOOL, &fa, &at, argv, envp);
    if (e) V.pid = -1;
    posix_spawnattr_destroy(&at);
    posix_spawn_file_actions_destroy(&fa);
    return e;
}

static void end_tool(void)
{
    if (V.pid <= 0) return;
    if (!child_gone()) kill(V.pid, SIGTERM);
    for (int i = 0; i < 200 && !child_gone(); i++) usleep(10000);
    if (!child_gone()) {
        kill(V.pid, SIGKILL);
        for (int i = 0; i < 200 && !child_gone(); i++) usleep(10000);
    }
    if (!child_gone()) fprintf(stderr, "X2V_VREC encoder %d did not exit\n", V.pid);
    V.pid = -1;
}

static int write_cfg(uint32_t bitrate)
{
    char b[1400];
    int n = snprintf(b, sizeof b,
        "{\"instance_active_num\":1,\"enable_perf_trace\":0,\"instances\":[{"
        "\"input\":\"/proc/self/fd/3\",\"output\":\"/proc/self/fd/4\",\"recon\":\"\",\"gmv\":\"\","
        "\"src_width\":%d,\"src_height\":%d,\"enc_width\":%d,\"enc_height\":%d,"
        "\"frame_rate_num\":24,\"frame_rate_den\":1,\"bitrate\":%u,"
        "\"input_alignment\":8,\"input_bitdepth\":8,\"codec_type\":\"H264\","
        "\"input_format\":\"NV12\",\"enc_mode\":\"storage\",\"enc_pic_num\":100000000,"
        "\"hw_core_num\":1,\"priority\":0,\"aging\":0,\"force_i_enc\":0,"
        "\"enable_performance_test\":0,\"enable_bandwidth_test\":0,"
        "\"enable_dynamic_frame_rate_test\":0,\"enable_debug_dump_test\":0,"
        "\"enable_force_idr_test\":0,\"enable_re_encode_test\":0,"
        "\"enable_custom_ref_test\":0,\"idr_interval\":24}]}\n",
        VR_W, VR_H, VR_W, VR_H, bitrate);
    if (n <= 0 || (size_t)n >= sizeof b) return EOVERFLOW;
    int fd = open(VR_CFG, O_WRONLY | O_CREAT | O_TRUNC | O_CLOEXEC, 0600);
    if (fd < 0) return errno;
    int e = write(fd, b, (size_t)n) == n ? 0 : EIO;
    close(fd);
    return e;
}

/* ---------- feeding ---------- */

static int put_frame(const uint8_t *p)
{
    size_t n = VR_FRAME;
    uint64_t limit = now_ns() + 3000000000ull;
    while (n) {
        ssize_t w = write(V.in_fd, p, n);
        if (w > 0) { p += w; n -= (size_t)w; continue; }
        if (w < 0 && errno == EINTR) continue;
        if (w < 0 && errno != EAGAIN) return errno;
        struct pollfd pf = { V.in_fd, POLLOUT, 0 };
        poll(&pf, 1, 100);
        if (atomic_load(&V.err)) return ECANCELED;
        if (child_gone()) return ECHILD;
        if (now_ns() > limit) return ETIMEDOUT;
    }
    return 0;
}

static void *feeder(void *unused)
{
    pthread_setname_np(pthread_self(), "x2v-vfeed");
    /* With the other recorder threads (resident.c): above the GUI and the viewfinder. */
    setpriority(PRIO_PROCESS, (id_t)syscall(SYS_gettid), -8);
    (void)unused;
    uint32_t flush = 0;
    pthread_mutex_lock(&V.mu);
    for (;;) {
        while (!atomic_load(&V.err) && ((!V.qn && !V.stopping) || V.fed - V.muxed >= VR_TS - 8))
            pthread_cond_wait(&V.cv, &V.mu);
        if (atomic_load(&V.err)) break;
        if (V.qn) {
            int k = V.q[V.qh];
            V.qh = (V.qh + 1) % VR_SLOTS;
            V.qn--;
            uint64_t ts = V.slot_ts[k], t0 = now_ns();
            pthread_mutex_unlock(&V.mu);
            if (filter) filter(V.slot[k], VR_W, VR_H);
            int e = put_frame(V.slot[k]);
            uint32_t ms = (uint32_t)((now_ns() - t0) / 1000000), cur = atomic_load(&V.feed_ms_max);
            while (ms > cur && !atomic_compare_exchange_weak(&V.feed_ms_max, &cur, ms)) {}
            pthread_mutex_lock(&V.mu);
            atomic_store(&V.slot_state[k], 0);
            if (e) { pthread_mutex_unlock(&V.mu); fail(e); return NULL; }
            V.ts[V.fed % VR_TS] = ts;
            V.fed++;
            pthread_cond_broadcast(&V.cv);
            continue;
        }
        /* Stopping with nothing queued: every real frame is fed. */
        if (!V.target_set) {
            V.target = V.fed;
            V.target_set = 1;
            if (V.muxed >= V.target) V.done = 1;
            pthread_cond_broadcast(&V.cv);
        }
        if (V.done || flush >= VR_FLUSH_MAX) break;
        pthread_mutex_unlock(&V.mu);
        int e = put_frame(V.slot[0]);
        pthread_mutex_lock(&V.mu);
        if (e) { pthread_mutex_unlock(&V.mu); fail(e); return NULL; }
        flush++;
        struct timespec until;
        clock_gettime(CLOCK_REALTIME, &until);
        until.tv_nsec += 30000000;
        if (until.tv_nsec >= 1000000000) { until.tv_sec++; until.tv_nsec -= 1000000000; }
        if (!V.done) pthread_cond_timedwait(&V.cv, &V.mu, &until);
    }
    pthread_mutex_unlock(&V.mu);
    return NULL;
}

/* ---------- stream side ---------- */

static int au_put(const uint8_t *p, size_t n)
{
    if (V.au_len + n + 4 > V.au_cap) {
        size_t cap = V.au_cap ? V.au_cap : (1u << 20);
        while (cap < V.au_len + n + 4) cap *= 2;
        if (cap > (64u << 20)) return ENOBUFS;
        uint8_t *a = realloc(V.au, cap);
        if (!a) return ENOMEM;
        V.au = a;
        V.au_cap = cap;
    }
    uint8_t *d = V.au + V.au_len;
    d[0] = (uint8_t)(n >> 24); d[1] = (uint8_t)(n >> 16); d[2] = (uint8_t)(n >> 8); d[3] = (uint8_t)n;
    memcpy(d + 4, p, n);
    V.au_len += n + 4;
    return 0;
}

static int write_all(int fd, const uint8_t *p, size_t n)
{
    while (n) {
        ssize_t w = write(fd, p, n);
        if (w < 0 && errno == EINTR) continue;
        if (w <= 0) return errno ? errno : EIO;
        p += w;
        n -= (size_t)w;
    }
    return 0;
}

static int64_t frame_no(uint64_t ts) { return llround((double)(int64_t)(ts - V.ts0) / VR_FRAME_US); }

/* The access unit gathered so far is complete. */
static int emit_au(void)
{
    if (!V.au_slices) { V.au_len = 0; return 0; }
    pthread_mutex_lock(&V.mu);
    uint32_t i = V.muxed, fed = V.fed, target = V.target_set ? V.target : UINT32_MAX;
    uint64_t t = V.ts[i % VR_TS], tn = i + 1 < fed ? V.ts[(i + 1) % VR_TS] : 0;
    pthread_mutex_unlock(&V.mu);
    size_t len = V.au_len;
    int key = V.au_key, e = 0;
    V.au_len = 0;
    V.au_slices = 0;
    if (i >= target) return 0;          /* a throwaway frame */
    if (i >= fed) return EPROTO;        /* more output than input */
    if (!i) {
        if (!key) return EPROTO;
        V.ts0 = t;
    }
    int64_t f0 = frame_no(t), f1 = i + 1 < fed ? frame_no(tn) : f0 + 1;
    uint32_t dur = (uint32_t)(f1 > f0 ? f1 - f0 : 1) * 1000u;
    if ((e = write_all(V.mov.fd, V.au, len))) return e;
    if (prr_mov_add_sample_ex(&V.mov, (uint32_t)len, dur, key)) return ENOMEM;
    atomic_fetch_add(&V.bytes, len);
    pthread_mutex_lock(&V.mu);
    V.muxed++;
    V.keys += key != 0;
    if (V.target_set && V.muxed >= V.target) V.done = 1;
    pthread_cond_broadcast(&V.cv);
    pthread_mutex_unlock(&V.mu);
    return 0;
}

static int keep(uint8_t *dst, uint32_t *len, const uint8_t *p, size_t n)
{
    if (*len) return 0;
    if (n > 256) return EOVERFLOW;
    memcpy(dst, p, n);
    *len = (uint32_t)n;
    return 0;
}

static int on_nal(const uint8_t *p, size_t n)
{
    if (!n) return 0;
    int t = p[0] & 31, e = 0;
    if (t == 1 || t == 5) {
        if (n > 1 && (p[1] & 0x80) && V.au_slices && (e = emit_au())) return e;  /* first_mb_in_slice == 0 */
        if (!V.au_slices) V.au_key = t == 5;
        V.au_slices++;
        return au_put(p, n);
    }
    /* Anything else after a picture's slices opens the next access unit. */
    if (V.au_slices && (e = emit_au())) return e;
    if (t == 7) return keep(V.sps, &V.sps_len, p, n);
    if (t == 8) return keep(V.pps, &V.pps_len, p, n);
    if (t == 9) return 0;
    return au_put(p, n);
}

static void *reader(void *unused)
{
    pthread_setname_np(pthread_self(), "x2v-vread");
    /* With the other recorder threads (resident.c): above the GUI and the viewfinder. */
    setpriority(PRIO_PROCESS, (id_t)syscall(SYS_gettid), -8);
    (void)unused;
    size_t cap = 4u << 20, len = 0, scan = 0;
    ptrdiff_t cur = -1;
    uint8_t *b = malloc(cap);
    if (!b) { fail(ENOMEM); return NULL; }
    uint64_t idle = now_ns();
    for (;;) {
        pthread_mutex_lock(&V.mu);
        int stop = V.done, lag = V.fed > V.muxed + VR_LAG || V.target_set;
        pthread_mutex_unlock(&V.mu);
        if (stop || atomic_load(&V.err)) break;
        if (len == cap) {
            uint8_t *nb = cap < (64u << 20) ? realloc(b, cap * 2) : NULL;
            if (!nb) { fail(ENOBUFS); break; }
            b = nb;
            cap *= 2;
        }
        ssize_t n = read(V.out_fd, b + len, cap - len);
        if (n <= 0) {
            if (n < 0 && errno != EAGAIN && errno != EINTR) { fail(errno); break; }
            struct pollfd pf = { V.out_fd, POLLIN, 0 };
            poll(&pf, 1, 100);
            if (child_gone()) { fail(ECHILD); break; }
            if (!lag) idle = now_ns();
            else if (now_ns() - idle > 5000000000ull) { fail(ETIMEDOUT); break; }
            continue;
        }
        len += (size_t)n;
        idle = now_ns();
        int e = 0;
        size_t i = scan;
        while (!e && i + 3 <= len) {
            const uint8_t *q = memchr(b + i + 2, 1, len - i - 2);
            if (!q) { i = len - 2; break; }
            size_t j = (size_t)(q - b);
            if (b[j - 1] || b[j - 2]) { i = j - 1; continue; }
            if (cur >= 0) {
                size_t end = j - 2;
                while (end > (size_t)cur && !b[end - 1]) end--;
                e = on_nal(b + cur, end - (size_t)cur);
            }
            cur = (ptrdiff_t)(j + 1);
            i = j + 1;
        }
        if (e) { fail(e); break; }
        size_t drop = cur >= 0 ? (size_t)cur : (i < len ? i : len);
        if (drop) memmove(b, b + drop, len - drop);
        len -= drop;
        scan = i > drop ? i - drop : 0;
        if (cur >= 0) cur = 0;
    }
    free(b);
    return NULL;
}

/* ---------- clip ---------- */

static uint32_t build_avcc(void)
{
    uint8_t *a = V.avcc;
    uint32_t n = 8;
    a[n++] = 1; a[n++] = V.sps[1]; a[n++] = V.sps[2]; a[n++] = V.sps[3];
    a[n++] = 0xff;                                 /* 4-byte lengths */
    a[n++] = 0xe1;
    a[n++] = (uint8_t)(V.sps_len >> 8); a[n++] = (uint8_t)V.sps_len;
    memcpy(a + n, V.sps, V.sps_len); n += V.sps_len;
    a[n++] = 1;
    a[n++] = (uint8_t)(V.pps_len >> 8); a[n++] = (uint8_t)V.pps_len;
    memcpy(a + n, V.pps, V.pps_len); n += V.pps_len;
    if (V.sps[1] == 100 || V.sps[1] == 110 || V.sps[1] == 122 || V.sps[1] == 144) {
        a[n++] = 0xfd;                             /* 4:2:0 */
        a[n++] = 0xf8;                             /* 8-bit luma */
        a[n++] = 0xf8;                             /* 8-bit chroma */
        a[n++] = 0;
    }
    a[0] = (uint8_t)(n >> 24); a[1] = (uint8_t)(n >> 16); a[2] = (uint8_t)(n >> 8); a[3] = (uint8_t)n;
    memcpy(a + 4, "avcC", 4);
    return n;
}

static void close_fifos(void)
{
    int *fd[] = { &V.in_fd, &V.out_fd, &V.in_keep, &V.out_keep };
    for (int i = 0; i < 4; i++) {
        if (*fd[i] >= 0) close(*fd[i]);
        *fd[i] = -1;
    }
}

/* pipe2 with both ends moved to 10 and up: dup2 onto the tool's 3 and 4 must never be a no-op that
 * keeps close-on-exec. */
static int high_pipe(int *r, int *w)
{
    int p[2];
    if (pipe2(p, O_CLOEXEC)) return errno;
    *r = fcntl(p[0], F_DUPFD_CLOEXEC, 10);
    *w = fcntl(p[1], F_DUPFD_CLOEXEC, 10);
    int e = *r < 0 || *w < 0 ? errno : 0;
    close(p[0]);
    close(p[1]);
    return e;
}

static uint64_t armed_ns;
static uint32_t armed_bitrate;

void vrec_disarm(void)
{
    if (atomic_load(&V.open)) return;
    end_tool();
    close_fifos();
    unlink(VR_CFG);
}

int vrec_arm(uint32_t bitrate)
{
    if (atomic_load(&V.open)) return EBUSY;
    if (V.pid > 0 && !child_gone() && armed_bitrate == bitrate) return 0;
    vrec_disarm();
    int e = high_pipe(&V.in_keep, &V.in_fd);
    if (!e) e = high_pipe(&V.out_fd, &V.out_keep);
    if (!e && (fcntl(V.in_fd, F_SETFL, O_NONBLOCK) || fcntl(V.out_fd, F_SETFL, O_NONBLOCK))) e = errno;
    if (!e) {
        fcntl(V.in_fd, F_SETPIPE_SZ, 1 << 20);
        fcntl(V.out_fd, F_SETPIPE_SZ, 1 << 20);
        e = write_cfg(bitrate);
    }
    if (!e) {
        V.child_done = 0;
        e = spawn_tool();
    }
    if (e) { close_fifos(); return e; }
    armed_ns = now_ns();
    armed_bitrate = bitrate;
    fprintf(stderr, "X2V_VREC armed pid=%d\n", V.pid);
    return 0;
}

int vrec_begin(int dirfd, uint32_t bitrate)
{
    if (atomic_load(&V.open)) return EBUSY;
    for (int i = 0; i < VR_SLOTS; i++)
        if (!V.slot[i] && !(V.slot[i] = malloc(VR_FRAME))) return ENOMEM;
    V.qh = V.qn = 0;
    V.fed = V.muxed = V.target = V.keys = 0;
    V.stopping = V.target_set = V.done = 0;
    V.au_len = 0; V.au_slices = 0;
    V.sps_len = V.pps_len = 0;
    atomic_store(&V.err, 0);
    atomic_store(&V.seen, 0); atomic_store(&V.dropped, 0); atomic_store(&V.feed_ms_max, 0);
    atomic_store(&V.bytes, 0);
    for (int i = 0; i < VR_SLOTS; i++) atomic_store(&V.slot_state[i], 0);
    int e = vrec_arm(bitrate);
    if (e) return e;
    /* An encoder armed only just now is still in the start that stalls the SSD; the clip waits it out. */
    for (uint64_t t = now_ns(); t < armed_ns + VR_SETTLE_NS; t = now_ns())
        usleep((useconds_t)((armed_ns + VR_SETTLE_NS - t) / 1000));
    if (prr_mov_openat_mp4(&V.mov, dirfd, VR_FILE, VR_W, VR_H, "avc1", 24000, 1000)) return errno ? errno : EIO;
    V.mov.compressor = "H.264";
    if ((e = pthread_create(&V.reader, NULL, reader, NULL))) {
        end_tool();
        prr_mov_close(&V.mov);
        unlinkat(dirfd, VR_FILE, 0);
        close_fifos();
        return e;
    }
    if ((e = pthread_create(&V.feeder, NULL, feeder, NULL))) {
        fail(e);
        pthread_join(V.reader, NULL);
        end_tool();
        prr_mov_close(&V.mov);
        unlinkat(dirfd, VR_FILE, 0);
        close_fifos();
        return e;
    }
    atomic_store(&V.open, 1);
    fprintf(stderr, "X2V_VREC begin pid=%d bitrate=%u\n", V.pid, bitrate);
    return 0;
}

uint32_t vrec_wait_output(uint32_t ms)
{
    uint64_t t0 = now_ns(), limit = t0 + (uint64_t)ms * 1000000ull;
    pthread_mutex_lock(&V.mu);
    while (!V.muxed && !atomic_load(&V.err) && now_ns() < limit) {
        pthread_mutex_unlock(&V.mu);
        usleep(5000);
        pthread_mutex_lock(&V.mu);
    }
    pthread_mutex_unlock(&V.mu);
    return (uint32_t)((now_ns() - t0) / 1000000ull);
}

void vrec_stats(struct vrec_stats *st)
{
    pthread_mutex_lock(&V.mu);
    st->fed = V.fed;
    st->frames = V.muxed;
    st->keys = V.keys;
    pthread_mutex_unlock(&V.mu);
    st->seen = atomic_load(&V.seen);
    st->dropped = atomic_load(&V.dropped);
    st->feed_ms_max = atomic_load(&V.feed_ms_max);
    st->bytes = atomic_load(&V.bytes);
    st->error = atomic_load(&V.err);
}

int vrec_end(struct vrec_stats *st)
{
    atomic_store(&V.open, 0);
    while (atomic_load(&V.in_flight)) usleep(1000);
    pthread_mutex_lock(&V.mu);
    V.stopping = 1;
    pthread_cond_broadcast(&V.cv);
    pthread_mutex_unlock(&V.mu);
    pthread_join(V.feeder, NULL);
    uint64_t limit = now_ns() + 3000000000ull;
    pthread_mutex_lock(&V.mu);
    while (!V.done && !atomic_load(&V.err) && now_ns() < limit) {
        pthread_mutex_unlock(&V.mu);
        usleep(10000);
        pthread_mutex_lock(&V.mu);
    }
    int incomplete = !V.done;
    pthread_mutex_unlock(&V.mu);
    if (incomplete) fail(ETIMEDOUT);
    pthread_join(V.reader, NULL);
    end_tool();
    close_fifos();
    unlink(VR_CFG);
    int e = atomic_load(&V.err);
    if (V.sps_len >= 4 && V.pps_len) {
        V.mov.entry_box = V.avcc;
        V.mov.entry_box_len = build_avcc();
    } else if (!e) {
        e = EPROTO;
    }
    if (prr_mov_close(&V.mov) && !e) e = EIO;
    V.mov.entry_box = NULL;
    V.mov.entry_box_len = 0;
    vrec_stats(st);
    st->error = e;
    fprintf(stderr, "X2V_VREC end fed=%u frames=%u keys=%u dropped=%u bytes=%llu error=%d\n", st->fed, st->frames,
            st->keys, st->dropped, (unsigned long long)st->bytes, e);
    return e;
}
