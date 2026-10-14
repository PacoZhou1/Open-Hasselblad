/* wlcap: what the screen shows, display planes included, through weston_capture_v1 (weston runs
 * with --debug, which opens the capture protocol to every client). Raw Wayland wire protocol: no
 * libwayland on the build side.
 *   wlcap <source> <count> <out.ppm|-> [gap_ms]
 * source: 0 writeback (the composed output, planes included), 1 framebuffer, 2 full_framebuffer,
 * 3 blending. The first capture is saved as PPM; each prints "i ms sig", where sig is a checksum
 * of the picture area: the sensor's noise changes it with every camera frame, so distinct
 * consecutive sigs count the frames the screen showed. */
#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/socket.h>
#include <sys/uio.h>
#include <sys/un.h>
#include <time.h>
#include <unistd.h>

/* The server takes new client ids only in sequence, without gaps. */
enum { ID_DISPLAY = 1 };
static uint32_t next_id = 2;
static uint32_t ID_REGISTRY, ID_SHM, ID_OUTPUT, ID_CAPTURE, ID_SOURCE, ID_POOL, ID_BUFFER;

static int sock = -1;
static uint32_t cb_wait, cb_done;
static uint32_t g_shm, g_output, g_capture, v_output;
static uint32_t fmt, got_size;
static int32_t cw, ch;
static int cap_state; /* 0 pending, 1 complete, 2 retry, 3 failed */

static uint64_t now_ms(void)
{
    struct timespec t;
    clock_gettime(CLOCK_MONOTONIC, &t);
    return (uint64_t)t.tv_sec * 1000u + (uint64_t)t.tv_nsec / 1000000u;
}

struct msg { uint32_t w[64]; int n; };
static void put(struct msg *m, uint32_t v) { m->w[m->n++] = v; }
static void put_str(struct msg *m, const char *s)
{
    uint32_t len = (uint32_t)strlen(s) + 1;
    put(m, len);
    memset(&m->w[m->n], 0, (len + 3) & ~3u);
    memcpy(&m->w[m->n], s, len);
    m->n += (int)((len + 3) / 4);
}

static int dispatch(int timeout_ms);
static int send_raw(uint32_t id, uint16_t op, const struct msg *a, int fd);

static int send_msg(uint32_t id, uint16_t op, const struct msg *a, int fd)
{
    int e = send_raw(id, op, a, fd);
    if (e) {
        fprintf(stderr, "send failed id=%u op=%u: %s\n", id, op, strerror(errno));
        /* A protocol error is the reason the server hung up: show it. */
        for (int i = 0; i < 50 && dispatch(20) >= 0; i++) {}
    }
    return e;
}

static int send_raw(uint32_t id, uint16_t op, const struct msg *a, int fd)
{
    uint32_t h[66];
    int n = a ? a->n : 0;
    h[0] = id;
    h[1] = ((uint32_t)(8 + 4 * n) << 16) | op;
    if (n) memcpy(h + 2, a->w, 4 * (size_t)n);
    struct iovec iov = { h, (size_t)(8 + 4 * n) };
    struct msghdr mh = { .msg_iov = &iov, .msg_iovlen = 1 };
    char cbuf[CMSG_SPACE(sizeof(int))];
    if (fd >= 0) {
        memset(cbuf, 0, sizeof cbuf);
        mh.msg_control = cbuf;
        mh.msg_controllen = sizeof cbuf;
        struct cmsghdr *c = CMSG_FIRSTHDR(&mh);
        c->cmsg_level = SOL_SOCKET;
        c->cmsg_type = SCM_RIGHTS;
        c->cmsg_len = CMSG_LEN(sizeof(int));
        memcpy(CMSG_DATA(c), &fd, sizeof fd);
    }
    return sendmsg(sock, &mh, 0) == (ssize_t)iov.iov_len ? 0 : -1;
}

static const char *arg_str(const uint32_t *p, uint32_t *words)
{
    uint32_t len = p[0];
    *words = 1 + (len + 3) / 4;
    return len ? (const char *)(p + 1) : NULL;
}

static void event(uint32_t id, uint16_t op, const uint32_t *a)
{
    uint32_t w;
    if (id == ID_DISPLAY && op == 0) {
        const char *s = arg_str(a + 2, &w);
        fprintf(stderr, "wl error object=%u code=%u: %s\n", a[0], a[1], s ? s : "");
        exit(3);
    }
    if (id == ID_REGISTRY && op == 0) {
        const char *iface = arg_str(a + 1, &w);
        uint32_t ver = a[1 + w];
        if (!iface) return;
        if (!strcmp(iface, "wl_shm")) g_shm = a[0];
        else if (!strcmp(iface, "wl_output") && !g_output) { g_output = a[0]; v_output = ver; }
        else if (!strcmp(iface, "weston_capture_v1")) g_capture = a[0];
        return;
    }
    if (cb_wait && id == cb_wait && op == 0) { cb_done = id; return; }
    if (ID_SOURCE && id == ID_SOURCE) {
        switch (op) {
        case 0: fmt = a[0]; break;
        case 1: cw = (int32_t)a[0]; ch = (int32_t)a[1]; got_size = 1; break;
        case 2: cap_state = 1; break;
        case 3: cap_state = 2; break;
        case 4: { const char *s = arg_str(a, &w); fprintf(stderr, "capture failed: %s\n", s ? s : "(null)"); cap_state = 3; } break;
        }
    }
}

static uint8_t rbuf[1 << 16];
static size_t rlen;

static int dispatch(int timeout_ms)
{
    uint64_t end = now_ms() + (uint64_t)timeout_ms;
    for (;;) {
        while (rlen >= 8) {
            uint32_t h[2];
            memcpy(h, rbuf, 8);
            uint32_t size = h[1] >> 16;
            if (size < 8 || size > sizeof rbuf) return -1;
            if (rlen < size) break;
            uint32_t a[16384];
            memcpy(a, rbuf + 8, size - 8);
            event(h[0], (uint16_t)(h[1] & 0xffff), a);
            memmove(rbuf, rbuf + size, rlen - size);
            rlen -= size;
            return 0;
        }
        if (now_ms() > end) return 1;
        char cbuf[CMSG_SPACE(8 * sizeof(int))];
        struct iovec iov = { rbuf + rlen, sizeof rbuf - rlen };
        struct msghdr mh = { .msg_iov = &iov, .msg_iovlen = 1, .msg_control = cbuf, .msg_controllen = sizeof cbuf };
        ssize_t n = recvmsg(sock, &mh, MSG_DONTWAIT);
        if (n > 0) {
            for (struct cmsghdr *c = CMSG_FIRSTHDR(&mh); c; c = CMSG_NXTHDR(&mh, c))
                if (c->cmsg_type == SCM_RIGHTS)
                    for (size_t k = 0; k < (c->cmsg_len - CMSG_LEN(0)) / sizeof(int); k++) {
                        int fd;
                        memcpy(&fd, CMSG_DATA(c) + k * sizeof fd, sizeof fd);
                        close(fd);
                    }
            rlen += (size_t)n;
        } else if (n == 0) {
            return -1;
        } else if (errno == EAGAIN) {
            usleep(1000);
        } else {
            return -1;
        }
    }
}

static int roundtrip(void)
{
    uint32_t cb = cb_wait = next_id++;
    struct msg m = { .n = 0 };
    put(&m, cb);
    if (send_msg(ID_DISPLAY, 0, &m, -1)) return -1;
    uint64_t end = now_ms() + 3000;
    while (cb_done != cb) {
        if (now_ms() > end || dispatch(100) < 0) return -1;
    }
    return 0;
}

static int wl_bind(uint32_t name, const char *iface, uint32_t ver, uint32_t id)
{
    struct msg m = { .n = 0 };
    put(&m, name);
    put_str(&m, iface);
    put(&m, ver);
    put(&m, id);
    return send_msg(ID_REGISTRY, 0, &m, -1);
}

int main(int argc, char **argv)
{
    if (argc < 4) { fprintf(stderr, "usage: wlcap <source> <count> <out.ppm|-> [gap_ms]\n"); return 2; }
    uint32_t source = (uint32_t)atoi(argv[1]);
    int count = atoi(argv[2]), gap = argc > 4 ? atoi(argv[4]) : 0;
    const char *out = argv[3];
    const char *dir = getenv("XDG_RUNTIME_DIR");
    signal(SIGPIPE, SIG_IGN);
    struct sockaddr_un sa = { .sun_family = AF_UNIX };
    snprintf(sa.sun_path, sizeof sa.sun_path, "%s/wayland-0", dir ? dir : "/tmp");
    sock = socket(AF_UNIX, SOCK_STREAM | SOCK_CLOEXEC, 0);
    if (sock < 0 || connect(sock, (struct sockaddr *)&sa, sizeof sa)) { perror("connect"); return 3; }
    struct msg m = { .n = 0 };
    put(&m, ID_REGISTRY = next_id++);
    if (send_msg(ID_DISPLAY, 1, &m, -1) || roundtrip()) { fprintf(stderr, "registry failed\n"); return 3; }
    if (!g_shm || !g_output || !g_capture) {
        fprintf(stderr, "missing globals shm=%u output=%u capture=%u\n", g_shm, g_output, g_capture);
        return 4;
    }
    ID_SHM = next_id++;
    ID_OUTPUT = next_id++;
    ID_CAPTURE = next_id++;
    if (wl_bind(g_shm, "wl_shm", 1, ID_SHM) || wl_bind(g_output, "wl_output", 1, ID_OUTPUT) ||
        wl_bind(g_capture, "weston_capture_v1", 1, ID_CAPTURE)) return 3;
    ID_SOURCE = next_id++;
    m.n = 0;
    put(&m, ID_OUTPUT);
    put(&m, source);
    put(&m, ID_SOURCE);
    if (send_msg(ID_CAPTURE, 1, &m, -1) || roundtrip()) return 3;
    for (uint64_t end = now_ms() + 2000; !got_size && now_ms() < end;) dispatch(100);
    if (!got_size || cw <= 0 || ch <= 0) { fprintf(stderr, "no size (fmt=0x%x)\n", fmt); return 5; }
    fprintf(stderr, "source=%u size=%dx%d drm_format=0x%08x\n", source, cw, ch, fmt);
    uint32_t shm_fmt = fmt == 0x34325241 ? 0 : fmt == 0x34325258 ? 1 : fmt;
    int32_t stride = cw * 4;
    size_t bytes = (size_t)stride * (size_t)ch;
    char path[64];
    snprintf(path, sizeof path, "%s/wlcap.%d", dir ? dir : "/tmp", getpid());
    int fd = open(path, O_RDWR | O_CREAT | O_EXCL | O_CLOEXEC, 0600);
    if (fd < 0 || unlink(path) || ftruncate(fd, (off_t)bytes)) { perror("shm"); return 3; }
    uint8_t *px = mmap(NULL, bytes, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    if (px == MAP_FAILED) { perror("mmap"); return 3; }
    m.n = 0;
    put(&m, ID_POOL = next_id++);
    put(&m, (uint32_t)bytes);
    if (send_msg(ID_SHM, 0, &m, fd)) return 3;
    m.n = 0;
    put(&m, ID_BUFFER = next_id++);
    put(&m, 0);
    put(&m, (uint32_t)cw);
    put(&m, (uint32_t)ch);
    put(&m, (uint32_t)stride);
    put(&m, shm_fmt);
    if (send_msg(ID_POOL, 0, &m, -1) || roundtrip()) return 3;
    uint64_t t0 = now_ms();
    for (int i = 0; i < count; i++) {
        cap_state = 0;
        m.n = 0;
        put(&m, ID_BUFFER);
        if (send_msg(ID_SOURCE, 1, &m, -1)) return 3;
        for (uint64_t end = now_ms() + 3000; !cap_state && now_ms() < end;)
            if (dispatch(100) < 0) return 3;
        if (cap_state != 1) {
            fprintf(stderr, "capture %d state=%d\n", i, cap_state);
            if (cap_state == 2) { roundtrip(); i--; continue; }
            return 6;
        }
        uint64_t sig = 1469598103934665603ull;
        for (int y = ch / 8; y < ch * 7 / 8; y += 3)
            for (int x = cw / 8; x < cw * 7 / 8; x += 3) {
                const uint8_t *p = px + (size_t)y * (size_t)stride + 4 * (size_t)x;
                sig = (sig ^ (uint64_t)(p[0] | p[1] << 8 | p[2] << 16)) * 1099511628211ull;
            }
        printf("%d %llu %016llx\n", i, (unsigned long long)(now_ms() - t0), (unsigned long long)sig);
        fflush(stdout);
        if (i == 0 && strcmp(out, "-")) {
            FILE *f = fopen(out, "wb");
            if (!f) { perror(out); return 3; }
            fprintf(f, "P6\n%d %d\n255\n", cw, ch);
            uint8_t *row = malloc((size_t)cw * 3);
            for (int y = 0; y < ch && row; y++) {
                const uint8_t *s = px + (size_t)y * (size_t)stride;
                for (int x = 0; x < cw; x++) {
                    row[3 * x] = s[4 * x + 2];
                    row[3 * x + 1] = s[4 * x + 1];
                    row[3 * x + 2] = s[4 * x];
                }
                fwrite(row, 1, (size_t)cw * 3, f);
            }
            free(row);
            fclose(f);
        }
        if (gap > 0) usleep((useconds_t)gap * 1000);
    }
    return 0;
}
