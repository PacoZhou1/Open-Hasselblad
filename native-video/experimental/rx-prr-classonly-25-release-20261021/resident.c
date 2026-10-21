/* Resident ProRes RAW receiver, preloaded into an owned camera-service running
 * the group13 MODE21 C24 graph. One session, many clips:
 *   RAW callback  -> copy into a source slot (drop when none is free)
 *   encode thread -> 4-way preprocess into an msenc frame slot, submit
 *   harvest thread-> copy the bitstream out of ION, release the stream pair
 *   write thread  -> append to the open clip's MOV
 *   ISP colour callback -> NV12 snapshot -> preview thread -> PPM on tmpfs
 * An H.264 clip instead takes every colour frame through the hardware encoder (vrec.c).
 * A CinemaDNG clip writes each RAW source slot as one DNG (dng.c) from two writer
 * threads, with an H.264 proxy of the colour frames alongside for playback.
 * Control is a polled command file "<seq> rec <dir> [h264|dng]" / "<seq> stop" / "<seq> quit";
 * status.json is rewritten atomically. Nothing here has a session deadline. */
#define _GNU_SOURCE 1
#include "shape.h"
#include "dng.h"
#include "awb.h"
#include "prr_enc.h"
#include "prr_mov.h"
#include "prr_pre.h"
#include "pv_bands.h"
#include "pv_raw.h"
#include "vrec.h"
#include "../source-receiver-adapter/normal_diagnostic/diag_pins.h"
#include <dlfcn.h>
#include <errno.h>
#include <fcntl.h>
#include <pthread.h>
#include <semaphore.h>
#include <stdatomic.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/resource.h>
#include <sys/stat.h>
#include <sys/syscall.h>
#include <time.h>
#include <unistd.h>

#define RESIDENT_TOKEN "GROUP13_MODE21C25_PRR_AF_V1"
#define LIVE_DIR "/tmp/x2v-live"
#define PRR_W 3888
#define PRR_H 2912
/* Source slots: three from the start; a DNG clip, whose slots stay busy until written,
 * adds the rest on first use. Seven ride out about 200 ms of SSD or CPU stall. */
#define SRC_SLOTS 7
#define BASE_SLOTS 2
#define SLOT_ABSENT 5
#define DNG_WRITERS 3
#define POOL_PARTS 4
/* Encoded frames are queued in one ring whose byte index is the clip's file offset (mod RING_BYTES),
 * so the writer sends whole aligned blocks straight from it with O_DIRECT: buffered writes into the
 * page cache top out near 150 MB/s here, under the 200 MB/s a noisy scene needs, and O_DIRECT runs
 * past 1 GB/s. The unaligned tail goes through the ordinary descriptor when the clip ends. */
#define RING_BYTES (32u << 20)
#define RING_FRAMES 64
#define DIO_ALIGN 4096u
#define DIO_MIN (1u << 20)
#define PV_W 1300
#define PV_H 970
#define PV_STRIDE 1536
#define PV_BYTES (PV_STRIDE * PV_H * 3 / 2)
#define PV_OW (PV_W / 2)
#define PV_OH (PV_H / 2)
#define H264_BITRATE 20000000u

extern int duss_hal_mem_get_size(void *, uint32_t *);
extern int duss_hal_mem_map(void *, void **);
extern int duss_hal_mem_unmap(void *);
extern int duss_hal_mem_sync_ext(void *, unsigned, unsigned, uint64_t);

typedef void (*native_fn)(const char *, const char *, void *, void *);
static native_fn original;
static int enabled;
static int isp_view;              /* X2V_ISP_VIEW=1: the colour stream feeds the display plane */
static _Atomic int released;

/* session_gate.c: absorb stock requests that would take group13 away. Off after "release". */
int x2v_session_guard(void) { return enabled && !atomic_load(&released); }
extern unsigned x2v_session_guard_absorbed(void);

static uint64_t now_ns(void)
{
    struct timespec t;
    clock_gettime(CLOCK_MONOTONIC, &t);
    return (uint64_t)t.tv_sec * 1000000000ull + (uint64_t)t.tv_nsec;
}
/* The recorder's threads, above the GUI and the viewfinder when the CPU is short: a viewfinder
 * at the frame rate took enough from the ProRes RAW preprocessing to drop frames. It is the
 * picture that should wait, not the clip. */
static void recorder_priority(void) { setpriority(PRIO_PROCESS, (id_t)syscall(SYS_gettid), -8); }

static uint32_t u32(const void *p, size_t o) { uint32_t v; memcpy(&v, (const char *)p + o, 4); return v; }
static uint64_t u64(const void *p, size_t o) { uint64_t v; memcpy(&v, (const char *)p + o, 8); return v; }
static int name_is(const char *a, const char *b) { return a && !strcmp(a, b); }

/* ---------- shared state ---------- */

enum { ST_STARTING, ST_IDLE, ST_RECORDING, ST_FINALIZING, ST_ERROR };
static const char *state_name[] = { "starting", "idle", "recording", "finalizing", "error" };
enum { MODE_PRR, MODE_H264, MODE_DNG };
static const char *mode_name[] = { "prores_raw", "h264", "dng" };

struct src_slot {
    uint8_t *data;
    _Atomic int state;           /* 0 free, 1 filling, 2 queued, 3 encoding or writing, SLOT_ABSENT */
    uint64_t ts;
    uint64_t copied_ns;          /* DNG: when the camera's callback finished the copy */
    uint32_t index;              /* DNG: frame number in the clip */
    float black;                 /* DNG: measured optical black */
};

struct ring_frame {
    uint64_t end;                /* ring index just past the frame */
    uint32_t size;
};

static struct {
    _Atomic int state, recording, in_flight;
    _Atomic uint32_t clip;       /* current clip generation */
    struct src_slot slot[SRC_SLOTS];
    int order[SRC_SLOTS], order_head, order_count;
    pthread_mutex_t mu;
    pthread_cond_t cv;           /* any pipeline progress */
    uint8_t *ring;
    uint64_t ring_in, ring_out;  /* filled / on disk */
    struct ring_frame fr[RING_FRAMES];
    int fr_head, fr_count;       /* frames not yet entirely on disk */
    int flushing;                /* clip ending: write every whole block, however few */
    uint64_t qbytes_max;
    int writer_busy, quit;
    struct prr_mov mov;
    int mov_open, dirfd, dfd;    /* dfd: the clip opened O_DIRECT, or ordinarily if that fails */
    int direct;
    int mode;                    /* MODE_* of the current or last clip */
    char clip_dir[256];
    char clip_name[96];          /* DNG frame files are <clip_name>_<frame>.dng */
    uint64_t clip_begin_ns;
    /* per-clip counters */
    _Atomic uint32_t seen, copied, dropped, lost, submitted, harvested, written;
    _Atomic uint64_t bytes, first_ts, last_ts;
    _Atomic uint32_t write_ms_max, copy_errors;
    /* Stall diagnosis: longest encode-side steps, and what the encode thread was doing at each drop. */
    _Atomic uint32_t acq_ms_max, pre_ms_max, sub_ms_max, harv_ms_max, copy_ms_max;
    _Atomic int enc_phase;       /* PH_* */
    _Atomic uint32_t drop_phase[4];
    int error;
    char last_clip[256];
    uint32_t last_frames, last_dropped;
    double last_seconds;
    /* preview: the viewfinder from the RAW port. Two RAW row buffers, so a frame can land while the
     * one before renders. */
    _Atomic int pvr_state[2];        /* 0 free, 1 filling, 2 ready, 3 rendering */
    _Atomic uint32_t pvr_seq[2], pvr_next;
    _Atomic uint32_t pv_seen, pv_gen, pv_us;
    uint8_t *pv_rgb;
    struct pvr_frame *pvr_rows[2];
    pthread_mutex_t pv_mu;
    pthread_cond_t pv_cv;
} S = { .mu = PTHREAD_MUTEX_INITIALIZER, .cv = PTHREAD_COND_INITIALIZER,
        .pv_mu = PTHREAD_MUTEX_INITIALIZER, .pv_cv = PTHREAD_COND_INITIALIZER, .dirfd = -1, .dfd = -1 };

static struct prr_enc enc;
static struct prr_pre pre;
static _Atomic int enc_ready;       /* encoder opened + pipeline threads live */
static pthread_mutex_t enc_mu = PTHREAD_MUTEX_INITIALIZER;
/* One post per accepted submit. prr_enc_next returns at once when nothing is
 * outstanding, so the harvester must block here instead of looping on it. */
static sem_t enc_jobs;

static const struct prr_meta default_meta = {
    2.161865234375f, 2.167236328125f, 1.0f,
    { 0.7141116f, 0.1032353f, 0.1331231f, 0.2757776f, 0.8515739f, -0.1273514f, 0.1016372f, -0.420501f, 1.407694f },
    3961
};

#define SENSOR_WHITE 64681.0f
static const struct dng_geom dng_geom = DNG_GEOM_MODE21;
_Static_assert(X2V_STRIDE == 2 * 3968 && X2V_HEIGHT >= 2944, "the DNG image is the MODE21 source slot");

/* A clip's white balance is measured once, on its first frame, so it cannot flicker.
 * default_meta's gains stay the matrix's calibration and the fallback. */
static float as_shot[2];
static struct prr_meta clip_meta;

/* `src`: the 16-bit frame, or with `packed` the DNG slot's 12-bit one. */
static void clip_wb(const void *src, int packed, float black)
{
    uint64_t t = now_ns();
    int e = packed ? awb_estimate12(&pre, src, black, &as_shot[0], &as_shot[1])
                   : awb_estimate(&pre, src, black, &as_shot[0], &as_shot[1]);
    if (e) {
        as_shot[0] = default_meta.wb_red;
        as_shot[1] = default_meta.wb_blue;
    }
    clip_meta = default_meta;
    clip_meta.wb_red = as_shot[0];
    clip_meta.wb_blue = as_shot[1];
    fprintf(stderr, "X2V_RESIDENT awb wb_red=%.3f wb_blue=%.3f%s ms=%u\n", as_shot[0], as_shot[1],
            e ? " (fallback)" : "", (unsigned)((now_ns() - t) / 1000000));
}

static void note_ms(_Atomic uint32_t *max, uint64_t since)
{
    uint32_t ms = (uint32_t)((now_ns() - since) / 1000000);
    if (ms > atomic_load(max)) atomic_store(max, ms);
}

/* ---------- callback side ---------- */

/* COPY_PACK12: the DNG image packed to 12 bits on the way instead of the frame copied, which
 * spares the writers a pass of their own over it: about 47 of 105 MB of memory traffic
 * per frame. COPY_VIEW: the sums of the RAW rows the viewfinder samples (pv_raw_take). */
enum { COPY_WHOLE, COPY_PACK12, COPY_VIEW };
static int map_copy(void *frame, void *dst, uint32_t bytes, int how)
{
    void *handle = (void *)(uintptr_t)u64(frame, 0x20), *p = NULL;
    uint32_t size = 0;
    if (!handle) return EINVAL;
    int e = duss_hal_mem_get_size(handle, &size);
    if (!e && (size < bytes || size > 33554432)) e = EOVERFLOW;
    if (e) return e;
    if ((e = duss_hal_mem_map(handle, &p))) return e;
    e = p ? duss_hal_mem_sync_ext(handle, 1, 0, bytes) : EFAULT;
    if (!e && how == COPY_PACK12) dng_pack12_to(dst, p, (size_t)dng_geom.stride_px * dng_geom.rows);
    else if (!e && how == COPY_VIEW) pv_raw_take(dst, p);
    else if (!e) memcpy(dst, p, bytes);
    int u = duss_hal_mem_unmap(handle);
    return e ? e : u;
}

static void on_raw(void *frame)
{
    atomic_fetch_add(&S.in_flight, 1);
    int ok = u32(frame, 0x28) == X2V_PIXEL && u32(frame, 0x38) == X2V_WIDTH && u32(frame, 0x3c) == X2V_HEIGHT &&
             u32(frame, 0x40) == X2V_STRIDE && u32(frame, 0x44) == 0 && u32(frame, 0xb0) == 1;
    if (atomic_load(&S.recording)) {
        atomic_fetch_add(&S.seen, 1);
        int k = -1;
        for (int i = 0; ok && i < SRC_SLOTS && k < 0; i++) {
            int z = 0;
            if (atomic_compare_exchange_strong(&S.slot[i].state, &z, 1)) k = i;
        }
        uint64_t t = now_ns();
        if (!ok || k < 0) {
            atomic_fetch_add(&S.dropped, 1);
            atomic_fetch_add(&S.drop_phase[atomic_load(&S.enc_phase) & 3], 1);
        } else if (map_copy(frame, S.slot[k].data, X2V_BYTES, S.mode == MODE_DNG ? COPY_PACK12 : COPY_WHOLE)) {
            atomic_fetch_add(&S.copy_errors, 1);
            atomic_fetch_add(&S.dropped, 1);
            atomic_store(&S.slot[k].state, 0);
        } else {
            note_ms(&S.copy_ms_max, t);
            uint64_t ts = u64(frame, 0x30);
            S.slot[k].ts = ts;
            S.slot[k].copied_ns = now_ns();
            uint64_t z = 0;
            atomic_compare_exchange_strong(&S.first_ts, &z, ts);
            atomic_store(&S.last_ts, ts);
            atomic_fetch_add(&S.copied, 1);
            pthread_mutex_lock(&S.mu);
            atomic_store(&S.slot[k].state, 2);
            S.order[(S.order_head + S.order_count) % SRC_SLOTS] = k;
            S.order_count++;
            pthread_cond_broadcast(&S.cv);
            pthread_mutex_unlock(&S.mu);
        }
    }
    /* After the clip's copy, which the slots wait on; skipped while both buffers are taken. While
     * ProRes RAW records, every other frame: a viewfinder at the frame rate (its sums here, the
     * GUI's decode) dropped ProRes RAW frames even with the recorder above it, at half it did not. */
    static unsigned raw_n;
    const unsigned n = raw_n++;
    /* In ISP view the screen shows the ISP's picture on the display plane, and this one only makes
     * the clip thumbnails and the supervisor's liveness count: two a second. */
    const int skip = isp_view ? n % 12 != 0 : atomic_load(&S.recording) && S.mode == MODE_PRR && (n & 1);
    for (int i = 0; ok && !skip && S.pvr_rows[1] && i < 2; i++) {
        int z = 0;
        if (!atomic_compare_exchange_strong(&S.pvr_state[i], &z, 1)) continue;
        if (map_copy(frame, S.pvr_rows[i], X2V_BYTES, COPY_VIEW)) { atomic_store(&S.pvr_state[i], 0); break; }
        atomic_store(&S.pvr_seq[i], atomic_fetch_add(&S.pvr_next, 1) + 1);
        pthread_mutex_lock(&S.pv_mu);
        atomic_store(&S.pvr_state[i], 2);
        pthread_cond_signal(&S.pv_cv);
        pthread_mutex_unlock(&S.pv_mu);
        break;
    }
    atomic_fetch_sub(&S.in_flight, 1);
}

/* Diagnostic "cdump": one colour frame, two invalidate+copy passes 5 ms apart, plus its descriptor.
 * As the display and the H.264 recorder get it, after colour_fix; "cdump raw": as the ISP sent it. */
static _Atomic int cdump;           /* 0 idle, 1 armed, 4 capturing, 2 captured, 3 failed */
static int cdump_raw;
static uint8_t *cdump_buf[2];
static uint8_t cdump_desc[0xc0];
static uint32_t cdump_size;

static void colour_capture(void *frame)
{
    void *handle = (void *)(uintptr_t)u64(frame, 0x20), *p = NULL;
    uint32_t size = 0;
    int e = handle ? duss_hal_mem_get_size(handle, &size) : EINVAL;
    if (!e && (size < PV_BYTES || size > (8u << 20))) e = EOVERFLOW;
    for (int i = 0; !e && i < 2; i++)
        if (!(cdump_buf[i] = malloc(size))) e = ENOMEM;
    if (!e && !(e = duss_hal_mem_map(handle, &p))) {
        for (int i = 0; !e && i < 2; i++) {
            if (i) usleep(5000);
            if (!(e = duss_hal_mem_sync_ext(handle, 1, 0, size))) memcpy(cdump_buf[i], p, size);
        }
        duss_hal_mem_unmap(handle);
    }
    memcpy(cdump_desc, frame, sizeof cdump_desc);
    cdump_size = size;
    atomic_store(&cdump, e ? 3 : 2);
}

/* The current scene-derived correction runs in the colour buffer before H.264
 * and display consume it. It reduces the original bands but can introduce scene
 * and history-dependent residuals; it is not a calibrated inverse response.
 * Only the colour callback calls it. */
static struct pv_bands col_bands;
static uint8_t col_rgb[PV_OW * PV_OH * 3];
static _Atomic uint32_t col_us, col_us_max;

/* Explicit, idle-only diagnostic. Both copies belong to one colour callback and
 * one mapping, before/after the existing correction. Allocate and write on the
 * command thread; the callback only copies. Retain buffers until process exit so
 * a timeout can never free memory still owned by the callback. */
static _Atomic int cpair; /* 0 idle, 1 armed, 4 callback owns, 2 complete */
static uint8_t *cpair_pre, *cpair_post;
static uint8_t cpair_desc[0xc0];
static struct pv_bands cpair_gains;
static uint64_t cpair_begin_ns, cpair_end_ns;
static uint32_t cpair_ordinal;

extern int x2v_preview_lattice_aligned(void);
static void colour_fix(void *frame)
{
    const int aligned = x2v_preview_lattice_aligned();
    /* The aligned ISP output does not need scene-derived band correction.
     * Keep same-frame diagnostics available without changing pixel values. */
    if (aligned && atomic_load(&cpair) != 1) return;
    void *handle = (void *)(uintptr_t)u64(frame, 0x20), *p = NULL;
    uint32_t size = 0;
    if (!handle || duss_hal_mem_get_size(handle, &size) || size < PV_BYTES || duss_hal_mem_map(handle, &p)) return;
    uint64_t t0 = now_ns();
    if (p && !duss_hal_mem_sync_ext(handle, 1, 0, PV_BYTES)) {
        int armed = 1;
        int pair = atomic_compare_exchange_strong(&cpair, &armed, 4);
        if (pair) {
            cpair_begin_ns = now_ns();
            cpair_ordinal = atomic_load(&S.pv_seen);
            memcpy(cpair_desc, frame, sizeof cpair_desc);
            memcpy(cpair_pre, p, PV_BYTES);
        }
        if (!aligned) pv_bands_measure_nv12(&col_bands, p, PV_STRIDE, PV_W, PV_H, col_rgb);
        if (pair) memcpy(&cpair_gains, &col_bands, sizeof col_bands);
        if (!aligned) {
            pv_bands_fix_nv12(&col_bands, p, PV_STRIDE, PV_W, PV_H);
            pv_bands_fix_luma_interior(p, PV_STRIDE, PV_W, PV_H);
            pv_bands_fix_luma_edges(p, PV_STRIDE, PV_W, PV_H);
            pv_edge_polish_uv(p, PV_STRIDE, PV_W, PV_H);
        }
        if (pair) {
            memcpy(cpair_post, p, PV_BYTES);
            cpair_end_ns = now_ns();
            atomic_store(&cpair, 2);
        }
        duss_hal_mem_sync_ext(handle, 2, 0, PV_BYTES);
    }
    duss_hal_mem_unmap(handle);
    uint32_t us = (uint32_t)((now_ns() - t0) / 1000);
    atomic_store(&col_us, us);
    if (us > atomic_load(&col_us_max)) atomic_store(&col_us_max, us);
}

static void on_colour(void *frame)
{
    int armed = 1;
    if (cdump_raw && atomic_compare_exchange_strong(&cdump, &armed, 4)) colour_capture(frame);
    if (u32(frame, 0x28) != 2 || u32(frame, 0x38) != PV_W || u32(frame, 0x3c) != PV_H ||
        u32(frame, 0x40) != PV_STRIDE || u32(frame, 0x4c) != PV_H || u32(frame, 0xb0) != 2)
        return;
    static int bands_ready;
    if (!bands_ready) { pv_bands_init(&col_bands); bands_ready = 1; }
    colour_fix(frame);
    armed = 1;
    if (!cdump_raw && atomic_compare_exchange_strong(&cdump, &armed, 4)) colour_capture(frame);
    vrec_colour(frame);
    atomic_fetch_add(&S.pv_seen, 1);
}

void cam_filter_dump_frame_data(const char *name, const char *port, void *cfg, void *frame)
{
    if (enabled && frame && name_is(port, X2V_PORT)) {
        if (name_is(name, X2V_NAME)) on_raw(frame);
        else if (name_is(name, "color_null")) on_colour(frame);
    }
    if (original) original(name, port, cfg, frame);
}

static int hook_bind(void)
{
    void *p = dlsym(RTLD_NEXT, "cam_filter_dump_frame_data");
    memcpy(&original, &p, sizeof p);
    Dl_info d = { 0 };
    if (!p || !dladdr(p, &d) || !d.dli_fname) return EINVAL;
    const char *b = strrchr(d.dli_fname, '/');
    b = b ? b + 1 : d.dli_fname;
    if (strcmp(b, "libdcam_frwk.so") || memcmp(p, original_dump_pin, sizeof original_dump_pin)) return EINVAL;
    uintptr_t got;
    memcpy(&got, (void *)((uintptr_t)p - 0x20a0b0 + 0x36f978), 8);
    return got == (uintptr_t)&cam_filter_dump_frame_data ? 0 : EINVAL;
}

/* ---------- preprocess pool ---------- */

static struct {
    pthread_mutex_t mu;
    pthread_cond_t go, done;
    unsigned gen;
    int pending;
    const uint16_t *src;
    uint16_t *dst;
    float black;
} P = { .mu = PTHREAD_MUTEX_INITIALIZER, .go = PTHREAD_COND_INITIALIZER, .done = PTHREAD_COND_INITIALIZER };

static void part_rows(int part)
{
    int h = pre.g.height;
    prr_pre_rows(&pre, P.src, P.dst, P.black, h * part / POOL_PARTS, h * (part + 1) / POOL_PARTS);
}

static void *pool_worker(void *arg)
{
    pthread_setname_np(pthread_self(), "x2v-pool");
    recorder_priority();
    int part = (int)(intptr_t)arg;
    unsigned seen = 0;
    for (;;) {
        pthread_mutex_lock(&P.mu);
        while (P.gen == seen) pthread_cond_wait(&P.go, &P.mu);
        seen = P.gen;
        pthread_mutex_unlock(&P.mu);
        part_rows(part);
        pthread_mutex_lock(&P.mu);
        if (--P.pending == 0) pthread_cond_signal(&P.done);
        pthread_mutex_unlock(&P.mu);
    }
    return NULL;
}

static void preprocess(const uint16_t *src, uint16_t *dst, float black)
{
    pthread_mutex_lock(&P.mu);
    P.src = src; P.dst = dst; P.black = black;
    P.pending = POOL_PARTS - 1;
    P.gen++;
    pthread_cond_broadcast(&P.go);
    pthread_mutex_unlock(&P.mu);
    part_rows(0);
    pthread_mutex_lock(&P.mu);
    while (P.pending) pthread_cond_wait(&P.done, &P.mu);
    pthread_mutex_unlock(&P.mu);
}

/* ---------- pipeline threads ---------- */

static void lose(void)
{
    atomic_fetch_add(&S.lost, 1);
    pthread_mutex_lock(&S.mu);
    pthread_cond_broadcast(&S.cv);
    pthread_mutex_unlock(&S.mu);
}

enum { PH_IDLE, PH_ACQUIRE, PH_PRE, PH_SUBMIT };

/* ---------- CinemaDNG ---------- */

/* The opening frames of a clip, where the drops have been: ms from clip start (copy, start)
 * and step durations, logged once at clip end. */
#define DNG_TRACE 32
struct dng_trace { uint16_t copy, start, pack, open, data, close; };

static uint16_t ms16(uint64_t from, uint64_t to)
{
    uint64_t ms = to > from ? (to - from) / 1000000 : 0;
    return ms > 65535 ? 65535 : (uint16_t)ms;
}

static struct {
    pthread_mutex_t mu;
    pthread_cond_t cv, wb_cv;
    int q[SRC_SLOTS], head, count;   /* slots waiting for a writer */
    int busy;                        /* writers inside a write */
    int ready;
    int wb_ready;                    /* this clip's white balance is in colour */
    _Atomic int error, buffered;     /* first write error of the clip; O_DIRECT refused */
    _Atomic uint32_t pack_ms_max;    /* class fix, per frame (on_raw packs) */
    _Atomic uint32_t open_ms_max, close_ms_max;
    struct dng_trace tr[DNG_TRACE];
    uint32_t proxy_begin_ms;
    struct dng_color colour;
} D = { .mu = PTHREAD_MUTEX_INITIALIZER, .cv = PTHREAD_COND_INITIALIZER, .wb_cv = PTHREAD_COND_INITIALIZER };

/* Encode thread: only what needs the frames in order (the black); the writers turn the
 * slot into its DNG in parallel. */
static void dng_prepare(int k, uint32_t index)
{
    atomic_store(&S.enc_phase, PH_PRE);
    uint64_t t = now_ns();
    float black = dng_black12(&pre, S.slot[k].data);
    note_ms(&S.pre_ms_max, t);
    S.slot[k].index = index;
    S.slot[k].black = black;
    atomic_fetch_add(&S.submitted, 1);
    pthread_mutex_lock(&D.mu);
    D.q[(D.head + D.count) % SRC_SLOTS] = k;
    D.count++;
    pthread_cond_signal(&D.cv);
    pthread_mutex_unlock(&D.mu);
}

static int pwrite_all(int fd, const void *p, size_t n, off_t at)
{
    while (n) {
        ssize_t w = pwrite(fd, p, n, at);
        if (w < 0 && errno == EINTR) continue;
        if (w <= 0) return w < 0 ? errno : EIO;
        p = (const uint8_t *)p + w;
        n -= (size_t)w;
        at += w;
    }
    return 0;
}

/* Pixels first, header last: only the header needs the clip's white balance, which frame 0's
 * writer is still measuring while the other writers start on frames 1 and 2. */
static int dng_write(uint8_t *hdr, int k, struct dng_trace *tr)
{
    char name[128];
    snprintf(name, sizeof name, "%s_%06u.dng", S.clip_name, S.slot[k].index);
    for (;;) {
        int direct = !atomic_load(&D.buffered);
        uint64_t t = now_ns();
        int fd = openat(S.dirfd, name, O_WRONLY | O_CREAT | O_TRUNC | O_CLOEXEC | (direct ? O_DIRECT : 0), 0644);
        note_ms(&D.open_ms_max, t);
        if (tr) tr->open = ms16(t, now_ns());
        if (fd < 0 && direct && errno == EINVAL) { atomic_store(&D.buffered, 1); continue; }
        if (fd < 0) return errno;
        t = now_ns();
        int e = pwrite_all(fd, S.slot[k].data, (size_t)dng_pixel_bytes(&dng_geom), DNG_HDR_BYTES);
        if (!e) {
            pthread_mutex_lock(&D.mu);
            while (!D.wb_ready) pthread_cond_wait(&D.wb_cv, &D.mu);
            pthread_mutex_unlock(&D.mu);
            if (dng_header(hdr, &dng_geom, &D.colour, S.slot[k].black, (uint32_t)pre.white, S.slot[k].index, 25)) {
                close(fd);
                unlinkat(S.dirfd, name, 0);
                return EINVAL;
            }
            e = pwrite_all(fd, hdr, DNG_HDR_BYTES, 0);
        }
        if (tr) tr->data = ms16(t, now_ns());
        t = now_ns();
        if (close(fd) && !e) e = errno;
        note_ms(&D.close_ms_max, t);
        if (tr) tr->close = ms16(t, now_ns());
        if (e == EINVAL && direct) {
            fprintf(stderr, "X2V_RESIDENT dng_direct_failed; buffered writes from frame %u\n", S.slot[k].index);
            atomic_store(&D.buffered, 1);
            continue;
        }
        /* A frame cut short (a full drive) would read as a broken one. */
        if (e) unlinkat(S.dirfd, name, 0);
        return e;
    }
}

static void *dng_thread(void *arg)
{
    pthread_setname_np(pthread_self(), "x2v-dng");
    recorder_priority();
    uint8_t *hdr = arg;
    for (;;) {
        pthread_mutex_lock(&D.mu);
        while (!D.count) pthread_cond_wait(&D.cv, &D.mu);
        int k = D.q[D.head];
        D.head = (D.head + 1) % SRC_SLOTS;
        D.count--;
        D.busy++;
        pthread_mutex_unlock(&D.mu);
        uint64_t t = now_ns();
        struct dng_trace *tr = S.slot[k].index < DNG_TRACE ? &D.tr[S.slot[k].index] : NULL;
        if (tr) {
            tr->copy = ms16(S.clip_begin_ns, S.slot[k].copied_ns);
            tr->start = ms16(S.clip_begin_ns, t);
        }
        uint8_t *px = S.slot[k].data;
        /* Before the class fix below changes the frame it measures. */
        if (!S.slot[k].index) {
            clip_wb(px, 1, S.slot[k].black);
            pthread_mutex_lock(&D.mu);
            D.colour.wb_red = as_shot[0];
            D.colour.wb_blue = as_shot[1];
            D.wb_ready = 1;
            pthread_cond_broadcast(&D.wb_cv);
            pthread_mutex_unlock(&D.mu);
            t = now_ns();
        }
        dng_fix_classes12(&pre, px);
        note_ms(&D.pack_ms_max, t);
        if (tr) tr->pack = ms16(t, now_ns());
        t = now_ns();
        int e = dng_write(hdr, k, tr);
        note_ms(&S.write_ms_max, t);
        atomic_store(&S.slot[k].state, 0);
        if (e) {
            int z = 0;
            atomic_compare_exchange_strong(&D.error, &z, e);
            lose();
        } else {
            atomic_fetch_add(&S.written, 1);
            atomic_fetch_add(&S.bytes, DNG_HDR_BYTES + dng_pixel_bytes(&dng_geom));
        }
        pthread_mutex_lock(&D.mu);
        D.busy--;
        pthread_cond_broadcast(&D.cv);
        pthread_mutex_unlock(&D.mu);
    }
    return NULL;
}

/* Every copied frame is on disk or lost, and no writer is inside a write. */
static int dng_drained(void)
{
    pthread_mutex_lock(&D.mu);
    int idle = !D.count && !D.busy;
    pthread_mutex_unlock(&D.mu);
    return idle && atomic_load(&S.written) + atomic_load(&S.lost) >= atomic_load(&S.copied);
}

static void *encode_thread(void *unused)
{
    pthread_setname_np(pthread_self(), "x2v-enc");
    recorder_priority();
    (void)unused;
    uint64_t index = 0;
    uint32_t clip_seen = 0;
    for (;;) {
        pthread_mutex_lock(&S.mu);
        atomic_store(&S.enc_phase, PH_IDLE);
        while (!S.order_count) pthread_cond_wait(&S.cv, &S.mu);
        int k = S.order[S.order_head];
        S.order_head = (S.order_head + 1) % SRC_SLOTS;
        S.order_count--;
        atomic_store(&S.slot[k].state, 3);
        pthread_mutex_unlock(&S.mu);

        uint32_t clip = atomic_load(&S.clip);
        if (clip != clip_seen) { clip_seen = clip; index = 0; }
        if (S.mode == MODE_DNG) { dng_prepare(k, (uint32_t)index++); continue; }
        uint16_t *dst = NULL;
        atomic_store(&S.enc_phase, PH_ACQUIRE);
        uint64_t t = now_ns();
        int fs = prr_enc_acquire_frame(&enc, &dst);
        note_ms(&S.acq_ms_max, t);
        if (fs < 0) { atomic_store(&S.slot[k].state, 0); lose(); continue; }
        const uint16_t *src = (const uint16_t *)S.slot[k].data;
        atomic_store(&S.enc_phase, PH_PRE);
        t = now_ns();
        float black = prr_pre_black(&pre, src);
        if (!index) clip_wb(src, 0, black);
        preprocess(src, dst, black);
        note_ms(&S.pre_ms_max, t);
        atomic_store(&S.slot[k].state, 0);
        int rc;
        uint64_t pts = index * 1000;
        atomic_store(&S.enc_phase, PH_SUBMIT);
        t = now_ns();
        while ((rc = prr_enc_submit(&enc, fs, pts, &clip_meta)) == -EAGAIN) usleep(1000);
        note_ms(&S.sub_ms_max, t);
        if (rc) { lose(); continue; }
        index++;
        atomic_fetch_add(&S.submitted, 1);
        sem_post(&enc_jobs);
    }
    return NULL;
}

static void ring_put(uint64_t at, const void *p, uint32_t n)
{
    size_t o = (size_t)(at % RING_BYTES), first = n < RING_BYTES - o ? n : RING_BYTES - o;
    memcpy(S.ring + o, p, first);
    if (first < n) memcpy(S.ring, (const uint8_t *)p + first, n - first);
}

static void *harvest_thread(void *unused)
{
    pthread_setname_np(pthread_self(), "x2v-harvest");
    recorder_priority();
    (void)unused;
    for (;;) {
        while (sem_wait(&enc_jobs)) {}
        struct prr_out out;
        int r;
        while ((r = prr_enc_next(&enc, &out, 200)) == -ETIMEDOUT) {}
        if (r) continue;
        uint64_t t = now_ns();
        uint32_t size = out.alen + out.blen;
        int ok = out.result == 0 && out.alen >= 0x98 && u32(out.a, 0) != 0 && !memcmp(out.a + 4, "prrf", 4) &&
                 size <= RING_BYTES;
        pthread_mutex_lock(&S.mu);
        while (ok && S.mov_open && (S.ring_in + size - S.ring_out > RING_BYTES || S.fr_count == RING_FRAMES))
            pthread_cond_wait(&S.cv, &S.mu);
        ok = ok && S.mov_open;
        uint64_t at = S.ring_in;
        pthread_mutex_unlock(&S.mu);
        if (ok) {
            ring_put(at, out.a, out.alen);
            if (out.blen) ring_put(at + out.alen, out.b, out.blen);
        }
        prr_enc_release(&enc, &out);
        note_ms(&S.harv_ms_max, t);
        pthread_mutex_lock(&S.mu);
        /* The clip may have been closed while copying. */
        ok = ok && S.mov_open && !prr_mov_add_sample(&S.mov, size);
        if (ok) {
            S.fr[(S.fr_head + S.fr_count) % RING_FRAMES] = (struct ring_frame){ at + size, size };
            S.fr_count++;
            S.ring_in = at + size;
            if (S.ring_in - S.ring_out > S.qbytes_max) S.qbytes_max = S.ring_in - S.ring_out;
            atomic_fetch_add(&S.harvested, 1);
            pthread_cond_broadcast(&S.cv);
        }
        pthread_mutex_unlock(&S.mu);
        if (!ok) lose();
    }
    return NULL;
}

/* Ring bytes [from, to) to the clip at the same offsets. */
static int ring_write(int fd, uint64_t from, uint64_t to)
{
    while (from < to) {
        size_t o = (size_t)(from % RING_BYTES), n = to - from < RING_BYTES - o ? (size_t)(to - from) : RING_BYTES - o;
        ssize_t w = pwrite(fd, S.ring + o, n, (off_t)from);
        if (w < 0 && errno == EINTR) continue;
        if (w <= 0) return -1;
        from += (uint64_t)w;
    }
    return 0;
}

/* Under S.mu: frames now entirely below `upto` are on disk, or lost if that write failed. */
static void retire_frames(uint64_t upto, int failed)
{
    while (S.fr_count && S.fr[S.fr_head].end <= upto) {
        if (failed) atomic_fetch_add(&S.lost, 1);
        else { atomic_fetch_add(&S.written, 1); atomic_fetch_add(&S.bytes, S.fr[S.fr_head].size); }
        S.fr_head = (S.fr_head + 1) % RING_FRAMES;
        S.fr_count--;
    }
}

static void *write_thread(void *unused)
{
    pthread_setname_np(pthread_self(), "x2v-write");
    recorder_priority();
    (void)unused;
    for (;;) {
        pthread_mutex_lock(&S.mu);
        uint64_t from, to;
        for (;;) {
            from = S.ring_out;
            to = S.ring_in & ~(uint64_t)(DIO_ALIGN - 1);
            if (S.mov_open && to > from && (to - from >= DIO_MIN || S.flushing)) break;
            pthread_cond_wait(&S.cv, &S.mu);
        }
        S.writer_busy = 1;
        int direct = S.direct, fd = direct ? S.dfd : S.mov.fd, ofd = S.mov.fd;
        pthread_mutex_unlock(&S.mu);

        uint64_t t = now_ns();
        int e = ring_write(fd, from, to), err = e ? errno : 0;
        if (e && direct && !ring_write(ofd, from, to)) {
            fprintf(stderr, "X2V_RESIDENT direct_write_failed errno=%d; ordinary writes from %llu\n", err,
                    (unsigned long long)from);
            e = 0;
            direct = -1;
        }
        note_ms(&S.write_ms_max, t);

        pthread_mutex_lock(&S.mu);
        if (direct < 0) S.direct = 0;
        S.ring_out = to;
        retire_frames(to, e);
        S.writer_busy = 0;
        pthread_cond_broadcast(&S.cv);
        pthread_mutex_unlock(&S.mu);
    }
    return NULL;
}

/* ---------- preview ---------- */


static struct pv_raw pvr;

/* The bottom half of a frame, on a second thread while nothing records: the render of a whole
 * frame on one core held the viewfinder near 20 fps. Recording, the recorders get those cores. */
static struct {
    pthread_mutex_t mu;
    pthread_cond_t cv;
    int ready, work, done;
    const struct pvr_frame *rows;
    uint8_t *rgb;
    struct pvr_k k;
} PH = { .mu = PTHREAD_MUTEX_INITIALIZER, .cv = PTHREAD_COND_INITIALIZER };

static void *preview_helper(void *unused)
{
    pthread_setname_np(pthread_self(), "x2v-pv2");
    (void)unused;
    setpriority(PRIO_PROCESS, (id_t)syscall(SYS_gettid), 10);
    for (;;) {
        pthread_mutex_lock(&PH.mu);
        while (!PH.work) pthread_cond_wait(&PH.cv, &PH.mu);
        pthread_mutex_unlock(&PH.mu);
        pv_raw_part(&PH.k, PH.rows, PH.rgb, PVR_H / 2, PVR_H, 1);
        pthread_mutex_lock(&PH.mu);
        PH.work = 0;
        PH.done = 1;
        pthread_cond_broadcast(&PH.cv);
        pthread_mutex_unlock(&PH.mu);
    }
    return NULL;
}

static void render_preview(const struct pvr_frame *rows, uint8_t *rgb, int split)
{
    struct pvr_k k[2];
    if (pv_raw_begin(&pvr, rows, &k[0])) return;
    if (!split || !PH.ready) {
        pv_raw_part(&k[0], rows, rgb, 0, PVR_H, 1);
        pv_raw_end(&pvr, k, 1);
        return;
    }
    pthread_mutex_lock(&PH.mu);
    PH.k = k[0];
    PH.rows = rows;
    PH.rgb = rgb;
    PH.done = 0;
    PH.work = 1;
    pthread_cond_broadcast(&PH.cv);
    pthread_mutex_unlock(&PH.mu);
    pv_raw_part(&k[0], rows, rgb, 0, PVR_H / 2, 1);
    pthread_mutex_lock(&PH.mu);
    while (!PH.done) pthread_cond_wait(&PH.cv, &PH.mu);
    k[1] = PH.k;
    pthread_mutex_unlock(&PH.mu);
    pv_raw_end(&pvr, k, 2);
}

static void *preview_thread(void *unused)
{
    pthread_setname_np(pthread_self(), "x2v-pv");
    (void)unused;
    /* Below the recorders when the CPU is short: at its own weight it took enough from the
     * ProRes RAW preprocessing to drop frames. Idle, it still runs at the frame rate. */
    setpriority(PRIO_PROCESS, (id_t)syscall(SYS_gettid), 10);
    char header[32];
    const size_t hlen = (size_t)snprintf(header, sizeof header, "P6\n%d %d\n255\n", PVR_W, PVR_H);
    const size_t rgb = (size_t)PVR_W * PVR_H * 3;
    pv_raw_init(&pvr, default_meta.matrix, default_meta.wb_red, default_meta.wb_blue, SENSOR_WHITE);
    memcpy(S.pv_rgb, header, hlen);
    for (;;) {
        pthread_mutex_lock(&S.pv_mu);
        while (atomic_load(&S.pvr_state[0]) != 2 && atomic_load(&S.pvr_state[1]) != 2)
            pthread_cond_wait(&S.pv_cv, &S.pv_mu);
        pthread_mutex_unlock(&S.pv_mu);
        /* The newest frame; one a newer frame has overtaken is not worth its render. */
        int b = -1;
        for (int i = 0; i < 2; i++)
            if (atomic_load(&S.pvr_state[i]) == 2 && (b < 0 || atomic_load(&S.pvr_seq[i]) > atomic_load(&S.pvr_seq[b]))) b = i;
        if (b < 0) continue;
        int two = 2;
        atomic_compare_exchange_strong(&S.pvr_state[1 - b], &two, 0);
        atomic_store(&S.pvr_state[b], 3);
        uint64_t t0 = now_ns();
        render_preview(S.pvr_rows[b], S.pv_rgb + hlen, !atomic_load(&S.recording));
        atomic_store(&S.pvr_state[b], 0);
        atomic_store(&S.pv_us, (uint32_t)((now_ns() - t0) / 1000));
        int fd = open(LIVE_DIR "/preview.ppm.tmp", O_WRONLY | O_CREAT | O_TRUNC | O_CLOEXEC, 0644);
        if (fd >= 0) {
            ssize_t w = write(fd, S.pv_rgb, hlen + rgb);
            close(fd);
            if (w == (ssize_t)(hlen + rgb) && !rename(LIVE_DIR "/preview.ppm.tmp", LIVE_DIR "/preview.ppm")) {
                /* The GUI decodes the image only when this changes; a decode and redraw cost it
                 * more than this side's conversion. */
                char g[16];
                int n = snprintf(g, sizeof g, "%u\n", atomic_fetch_add(&S.pv_gen, 1) + 1);
                int gfd = open(LIVE_DIR "/preview.gen", O_WRONLY | O_CREAT | O_TRUNC | O_CLOEXEC, 0644);
                if (gfd >= 0) {
                    ssize_t gw = write(gfd, g, (size_t)n);
                    (void)gw;
                    close(gfd);
                }
            }
        }
    }
    return NULL;
}

/* ---------- control ---------- */

static const char *stall_json(char *b, size_t n)
{
    snprintf(b, n, "\"copy_ms_max\":%u,\"acq_ms_max\":%u,\"pre_ms_max\":%u,\"sub_ms_max\":%u,\"harv_ms_max\":%u,"
             "\"drop_phase\":[%u,%u,%u,%u]",
             atomic_load(&S.copy_ms_max), atomic_load(&S.acq_ms_max), atomic_load(&S.pre_ms_max), atomic_load(&S.sub_ms_max),
             atomic_load(&S.harv_ms_max), atomic_load(&S.drop_phase[PH_IDLE]), atomic_load(&S.drop_phase[PH_ACQUIRE]),
             atomic_load(&S.drop_phase[PH_PRE]), atomic_load(&S.drop_phase[PH_SUBMIT]));
    return b;
}

static void write_status(unsigned seq_ack)
{
    char b[2048], st[192];
    uint32_t written = atomic_load(&S.written), seen = atomic_load(&S.seen), copied = atomic_load(&S.copied);
    uint32_t dropped = atomic_load(&S.dropped);
    uint64_t f0 = atomic_load(&S.first_ts), f1 = atomic_load(&S.last_ts), bytes = atomic_load(&S.bytes);
    if (S.mode == MODE_H264) {
        struct vrec_stats v;
        vrec_stats(&v);
        written = v.frames; seen = v.seen; copied = v.fed; dropped = v.dropped; bytes = v.bytes;
        f0 = f1 = 0;
    }
    double secs = atomic_load(&S.state) == ST_RECORDING || atomic_load(&S.state) == ST_FINALIZING
                      ? (double)(now_ns() - S.clip_begin_ns) / 1e9 : 0;
    int n = snprintf(b, sizeof b,
        "{\"schema\":1,\"token\":\"" RESIDENT_TOKEN "\",\"state\":\"%s\",\"seq_ack\":%u,\"clip\":\"%s\",\"codec\":\"%s\","
        "\"seconds\":%.2f,\"seen\":%u,\"copied\":%u,\"dropped\":%u,\"lost\":%u,\"submitted\":%u,"
        "\"harvested\":%u,\"written\":%u,\"bytes\":%llu,\"source_span_raw\":%llu,\"queue_max\":%llu,"
        "\"write_ms_max\":%u,\"copy_errors\":%u,\"error\":%d,\"encoder_ready\":%d,\"preview_gen\":%u,\"preview_seen\":%u,"
        "\"preview_us\":%u,\"isp_view\":%d,\"colour_fix_us\":%u,\"colour_fix_us_max\":%u,\"direct\":%d,%s,"
        "\"guard\":%d,\"guard_absorbed\":%u,"
        "\"last_clip\":\"%s\",\"last_frames\":%u,\"last_dropped\":%u,\"last_seconds\":%.2f,\"uptime_ms\":%llu}\n",
        state_name[atomic_load(&S.state)], seq_ack, S.clip_dir, mode_name[S.mode], secs, seen, copied,
        dropped, atomic_load(&S.lost), atomic_load(&S.submitted), atomic_load(&S.harvested), written,
        (unsigned long long)bytes, (unsigned long long)(f1 - f0), (unsigned long long)S.qbytes_max,
        atomic_load(&S.write_ms_max), atomic_load(&S.copy_errors), S.error, atomic_load(&enc_ready), atomic_load(&S.pv_gen),
        atomic_load(&S.pv_seen), atomic_load(&S.pv_us), isp_view, atomic_load(&col_us), atomic_load(&col_us_max),
        S.direct, stall_json(st, sizeof st), x2v_session_guard(),
        x2v_session_guard_absorbed(),
        S.last_clip, S.last_frames, S.last_dropped, S.last_seconds,
        (unsigned long long)(now_ns() / 1000000));
    if (n <= 0 || (size_t)n >= sizeof b) return;
    int fd = open(LIVE_DIR "/status.json.tmp", O_WRONLY | O_CREAT | O_TRUNC | O_CLOEXEC, 0644);
    if (fd < 0) return;
    ssize_t w = write(fd, b, (size_t)n);
    close(fd);
    if (w == n) rename(LIVE_DIR "/status.json.tmp", LIVE_DIR "/status.json");
}

static int ensure_encoder(void)
{
    if (atomic_load(&enc_ready)) return 0;
    pthread_mutex_lock(&enc_mu);
    int e = 0;
    if (!atomic_load(&enc_ready)) {
        static const struct prr_pre_geom geom = PRR_PRE_GEOM_MODE21;
        /* 10 MB primary + 10 MB overflow per pair; standard-tier frames measured 2.2-7.7 MB. */
        struct prr_enc_cfg cfg = { PRR_W, PRR_H, geom.dst_stride_px * 2, 0, 0, 2, 2, 0, 1, 10u << 20 };
        int rc = prr_enc_open(&enc, &cfg);
        e = rc < 0 ? -rc : rc;
        if (e) {
            fprintf(stderr, "X2V_RESIDENT encoder_open_fail stage=%d rc=%d stream_bytes=%u\n", enc.open_stage, e, enc.stream_bytes);
            prr_enc_close(&enc);
        }
        pthread_t th;
        if (!e && !S.ring && posix_memalign((void **)&S.ring, DIO_ALIGN, RING_BYTES)) { S.ring = NULL; e = ENOMEM; }
        /* Resident pages: a fault into swap mid-clip would stall the writer. Best effort. */
        if (!e && mlock(S.ring, RING_BYTES)) memset(S.ring, 0, RING_BYTES);
        if (!e) e = pthread_create(&th, NULL, harvest_thread, NULL);
        if (!e) e = pthread_create(&th, NULL, write_thread, NULL);
        if (!e) atomic_store(&enc_ready, 1);
        fprintf(stderr, "X2V_RESIDENT encoder_ready rc=%d\n", e);
    }
    pthread_mutex_unlock(&enc_mu);
    return e;
}

/* First DNG clip: the extra source slots, a header buffer per writer, the writers. */
static int ensure_dng(void)
{
    if (D.ready) return 0;
    int e = 0;
    /* The base slots too: faulted in by the camera's callback, a boot's first clip copied its
     * opening frames late enough to run the slots out. */
    for (int i = 0; i < BASE_SLOTS; i++)
        if (S.slot[i].data && !atomic_load(&S.slot[i].state)) memset(S.slot[i].data, 0, X2V_BYTES);
    for (int i = BASE_SLOTS; !e && i < SRC_SLOTS; i++) {
        if (!S.slot[i].data && posix_memalign((void **)&S.slot[i].data, DIO_ALIGN, X2V_BYTES)) {
            S.slot[i].data = NULL;
            e = ENOMEM;
        }
        /* Fault the pages in here, not in the camera's callback on the first copy. */
        if (!e) memset(S.slot[i].data, 0, X2V_BYTES);
        if (!e) atomic_store(&S.slot[i].state, 0);
    }
    D.colour.wb_red = D.colour.cal_red = default_meta.wb_red;
    D.colour.wb_blue = D.colour.cal_blue = default_meta.wb_blue;
    memcpy(D.colour.cam_to_xyz, default_meta.matrix, sizeof D.colour.cam_to_xyz);
    pthread_t th;
    for (int i = 0; !e && i < DNG_WRITERS; i++) {
        void *hdr = NULL;
        if (posix_memalign(&hdr, DIO_ALIGN, DNG_HDR_BYTES)) e = ENOMEM;
        if (!e) e = pthread_create(&th, NULL, dng_thread, hdr);
    }
    if (!e) D.ready = 1;
    fprintf(stderr, "X2V_RESIDENT dng_ready rc=%d\n", e);
    return e;
}

static void reset_counters(void)
{
    atomic_store(&S.seen, 0); atomic_store(&S.copied, 0); atomic_store(&S.dropped, 0);
    atomic_store(&S.lost, 0); atomic_store(&S.submitted, 0); atomic_store(&S.harvested, 0);
    atomic_store(&S.written, 0); atomic_store(&S.bytes, 0); atomic_store(&S.first_ts, 0);
    atomic_store(&S.last_ts, 0); atomic_store(&S.write_ms_max, 0); atomic_store(&S.copy_errors, 0);
    atomic_store(&S.acq_ms_max, 0); atomic_store(&S.pre_ms_max, 0); atomic_store(&S.sub_ms_max, 0);
    atomic_store(&S.harv_ms_max, 0); atomic_store(&S.copy_ms_max, 0);
    for (int i = 0; i < 4; i++) atomic_store(&S.drop_phase[i], 0);
}

/* The H.264 encoder for the next H.264 clip or DNG proxy, started while nothing records. */
static void arm_proxy(void)
{
    int e = vrec_arm(H264_BITRATE);
    if (e) fprintf(stderr, "X2V_RESIDENT proxy_arm error=%d\n", e);
}

static int begin_h264(const char *dir)
{
    int d = open(dir, O_RDONLY | O_DIRECTORY | O_CLOEXEC);
    if (d < 0) return errno;
    int e = vrec_begin(d, H264_BITRATE);
    if (e) {
        fprintf(stderr, "X2V_RESIDENT clip_begin codec=h264 error=%d\n", e);
        close(d);
        return e;
    }
    S.mode = MODE_H264;
    S.dirfd = d;
    S.direct = 0;
    snprintf(S.clip_dir, sizeof S.clip_dir, "%s", dir);
    atomic_fetch_add(&S.clip, 1);
    S.clip_begin_ns = now_ns();
    S.error = 0;
    atomic_store(&S.state, ST_RECORDING);
    return 0;
}

/* The proxy is what the camera plays back; without one the DNG frames still record. */
static int proxy_on;

/* From its first frame, the proxy encoder's wake stalls the SSD for 0.1-0.6 s. Small direct writes
 * show when it is over: one that was slow comes back fast, or none was slow for 250 ms. */
static uint32_t wait_ssd(int dirfd, int *slow)
{
    static uint8_t probe[DIO_ALIGN] __attribute__((aligned(DIO_ALIGN)));
    uint64_t t0 = now_ns();
    int fd = openat(dirfd, ".x2v-probe", O_WRONLY | O_CREAT | O_TRUNC | O_DIRECT | O_CLOEXEC, 0644);
    *slow = now_ns() - t0 > 30000000ull;
    for (uint64_t t = now_ns(); fd >= 0 && t < t0 + 900000000ull; t = now_ns()) {
        if (pwrite(fd, probe, sizeof probe, 0) != (ssize_t)sizeof probe) break;
        if (now_ns() - t > 30000000ull) *slow = 1;
        else if (*slow || now_ns() - t0 > 250000000ull) break;
        usleep(10000);
    }
    if (fd >= 0) {
        close(fd);
        unlinkat(dirfd, ".x2v-probe", 0);
    }
    return ms16(t0, now_ns());
}

static int begin_dng(const char *dir)
{
    int e = ensure_dng();
    if (e) return e;
    if (!dng_drained()) return EBUSY;
    int d = open(dir, O_RDONLY | O_DIRECTORY | O_CLOEXEC);
    if (d < 0) return errno;
    const char *b = strrchr(dir, '/');
    reset_counters();
    atomic_store(&D.error, 0);
    atomic_store(&D.pack_ms_max, 0);
    atomic_store(&D.open_ms_max, 0);
    atomic_store(&D.close_ms_max, 0);
    memset(D.tr, 0, sizeof D.tr);
    D.wb_ready = 0;
    pthread_mutex_lock(&S.mu);
    S.mode = MODE_DNG;
    S.dirfd = d;
    S.direct = !atomic_load(&D.buffered);
    snprintf(S.clip_dir, sizeof S.clip_dir, "%s", dir);
    snprintf(S.clip_name, sizeof S.clip_name, "%s", b ? b + 1 : dir);
    atomic_fetch_add(&S.clip, 1);
    pthread_mutex_unlock(&S.mu);
    uint64_t t = now_ns();
    int pe = vrec_begin(d, H264_BITRATE);
    proxy_on = !pe;
    /* The DNG frames start once the proxy's encoder is awake: its wake stalls the SSD, and inside
     * the clip that ran the slots out. The proxy leads the DNG frames by that wait. */
    if (proxy_on) {
        uint32_t out_ms = vrec_wait_output(1500);
        int slow = 0;
        uint32_t ssd_ms = wait_ssd(d, &slow);
        fprintf(stderr, "X2V_RESIDENT dng_start proxy_out_ms=%u ssd_wait_ms=%u stalled=%d\n", out_ms, ssd_ms, slow);
    }
    D.proxy_begin_ms = ms16(t, now_ns());
    if (pe) fprintf(stderr, "X2V_RESIDENT dng_proxy_begin error=%d\n", pe);
    S.clip_begin_ns = now_ns();
    S.error = 0;
    atomic_store(&S.state, ST_RECORDING);
    atomic_store(&S.recording, 1);
    return 0;
}

static int begin_clip(const char *dir, int mode)
{
    if (strlen(dir) >= sizeof S.clip_dir || dir[0] != '/') return EINVAL;
    if (mode == MODE_H264) return begin_h264(dir);
    if (mode == MODE_DNG) return begin_dng(dir);
    int ee = ensure_encoder();
    if (ee) return ee;
    pthread_mutex_lock(&S.mu);
    int busy = S.writer_busy || S.fr_count || prr_enc_pending(&enc);
    pthread_mutex_unlock(&S.mu);
    if (busy) return EBUSY;
    int d = open(dir, O_RDONLY | O_DIRECTORY | O_CLOEXEC);
    if (d < 0) return errno;
    struct prr_mov m;
    if (prr_mov_openat(&m, d, "clip.partial.mov", PRR_W, PRR_H, "aprn", 25000, 1000)) {
        int e = errno ? errno : EIO;
        close(d);
        return e;
    }
    /* The ring starts at file offset 0, so its first block carries the header just written. */
    int rfd = openat(d, "clip.partial.mov", O_RDONLY | O_CLOEXEC);
    ssize_t hn = rfd < 0 ? -1 : pread(rfd, S.ring, (size_t)m.pos, 0);
    if (rfd >= 0) close(rfd);
    int direct = 1, dfd = openat(d, "clip.partial.mov", O_WRONLY | O_DIRECT | O_CLOEXEC);
    if (dfd < 0) { direct = 0; dfd = openat(d, "clip.partial.mov", O_WRONLY | O_CLOEXEC); }
    if (hn != (ssize_t)m.pos || dfd < 0) {
        int e = hn < 0 || dfd < 0 ? errno : EIO;
        if (dfd >= 0) close(dfd);
        prr_mov_close(&m);
        unlinkat(d, "clip.partial.mov", 0);
        close(d);
        return e ? e : EIO;
    }
    reset_counters();
    pthread_mutex_lock(&S.mu);
    S.mode = MODE_PRR;
    S.mov = m;
    S.mov_open = 1;
    S.dirfd = d;
    S.dfd = dfd;
    S.direct = direct;
    S.ring_out = 0;
    S.ring_in = m.pos;
    S.fr_head = S.fr_count = 0;
    S.flushing = 0;
    S.qbytes_max = 0;
    snprintf(S.clip_dir, sizeof S.clip_dir, "%s", dir);
    atomic_fetch_add(&S.clip, 1);
    pthread_mutex_unlock(&S.mu);
    S.clip_begin_ns = now_ns();
    S.error = 0;
    atomic_store(&S.state, ST_RECORDING);
    atomic_store(&S.recording, 1);
    return 0;
}

/* Under S.mu: every frame is in the ring or lost, and only the unaligned tail is left to write. */
static int drained(void)
{
    return atomic_load(&S.written) + atomic_load(&S.lost) + (uint32_t)S.fr_count >= atomic_load(&S.copied) &&
           !S.writer_busy && S.ring_out == (S.ring_in & ~(uint64_t)(DIO_ALIGN - 1));
}

/* clip.json, then the clip directory is closed and the result becomes the last clip. */
static void finish_clip(const char *j, int n, uint32_t frames, uint32_t dropped, double secs, int e)
{
    int fd = openat(S.dirfd, "clip.json", O_WRONLY | O_CREAT | O_TRUNC | O_CLOEXEC, 0644);
    if (fd >= 0) {
        if (n > 0 && write(fd, j, (size_t)n) == n) fsync(fd);
        close(fd);
    }
    fsync(S.dirfd);
    close(S.dirfd);
    S.dirfd = -1;
    snprintf(S.last_clip, sizeof S.last_clip, "%s", S.clip_dir);
    S.last_frames = frames;
    S.last_dropped = dropped;
    S.last_seconds = secs;
    S.clip_dir[0] = 0;
    S.error = e;
    atomic_store(&S.state, e ? ST_ERROR : ST_IDLE);
}

static void end_h264(void)
{
    atomic_store(&S.state, ST_FINALIZING);
    struct vrec_stats v;
    int e = vrec_end(&v);
    double secs = (double)(now_ns() - S.clip_begin_ns) / 1e9;
    /* Whatever reached the file is playable, so keep it even when the clip ended in error. */
    if (!v.frames) unlinkat(S.dirfd, "clip.partial.mp4", 0);
    else if (syscall(SYS_renameat2, S.dirfd, "clip.partial.mp4", S.dirfd, "clip.mp4", 1u) && !e) e = errno;
    char j[768];
    int n = snprintf(j, sizeof j,
        "{\"schema\":1,\"format\":\"H.264\",\"fourcc\":\"avc1\",\"width\":1300,\"height\":970,\"fps\":25,"
        "\"frames\":%u,\"dropped\":%u,\"lost\":%u,\"seen\":%u,\"keyframes\":%u,\"bytes\":%llu,\"seconds\":%.3f,"
        "\"duration\":%.3f,\"bitrate\":%u,\"feed_ms_max\":%u,\"error\":%d}\n",
        v.frames, v.dropped, v.fed - v.frames, v.seen, v.keys, (unsigned long long)v.bytes, secs, v.frames / 25.0,
        H264_BITRATE, v.feed_ms_max, e);
    finish_clip(j, n, v.frames, v.dropped, secs, e);
    fprintf(stderr, "X2V_RESIDENT clip_end codec=h264 frames=%u dropped=%u seconds=%.2f error=%d\n",
            v.frames, v.dropped, secs, e);
    arm_proxy();
}

static void end_dng(unsigned seq)
{
    atomic_store(&S.state, ST_FINALIZING);
    atomic_store(&S.recording, 0);
    while (atomic_load(&S.in_flight)) usleep(1000);
    uint64_t limit = now_ns() + 20000000000ull;
    while (!dng_drained() && now_ns() < limit) {
        write_status(seq);
        usleep(20000);
    }
    int e = dng_drained() ? atomic_load(&D.error) : ETIMEDOUT;
    struct vrec_stats v = { 0 };
    int pe = proxy_on ? vrec_end(&v) : -1;
    if (proxy_on) {
        if (!v.frames) unlinkat(S.dirfd, "clip.partial.mp4", 0);
        else if (syscall(SYS_renameat2, S.dirfd, "clip.partial.mp4", S.dirfd, "proxy.mp4", 1u) && !pe) pe = errno;
    }
    proxy_on = 0;
    /* The pixels went straight to the device; this settles the files' sizes and allocation. */
    if (syscall(SYS_syncfs, S.dirfd) && !e) e = errno;
    double secs = (double)(now_ns() - S.clip_begin_ns) / 1e9;
    uint32_t written = atomic_load(&S.written);
    char j[1024], st[192];
    int n = snprintf(j, sizeof j,
        "{\"schema\":1,\"format\":\"CinemaDNG\",\"width\":%u,\"height\":%u,\"bits\":%u,\"fps\":25,\"frames\":%u,"
        "\"dropped\":%u,\"lost\":%u,\"seen\":%u,\"bytes\":%llu,\"seconds\":%.3f,\"duration\":%.3f,\"write_ms_max\":%u,"
        "\"pack_ms_max\":%u,\"direct\":%d,\"proxy_frames\":%u,\"proxy_dropped\":%u,\"proxy_size\":%llu,"
        "\"proxy_error\":%d,\"wb\":[%.4f,%.4f],%s,\"error\":%d}\n",
        dng_geom.crop_w, dng_geom.crop_h, dng_geom.bits, written, atomic_load(&S.dropped), atomic_load(&S.lost),
        atomic_load(&S.seen), (unsigned long long)atomic_load(&S.bytes), secs, written / 25.0,
        atomic_load(&S.write_ms_max), atomic_load(&D.pack_ms_max), !atomic_load(&D.buffered), v.frames, v.dropped,
        (unsigned long long)v.bytes, pe, D.colour.wb_red, D.colour.wb_blue, stall_json(st, sizeof st), e);
    finish_clip(j, n, written, atomic_load(&S.dropped), secs, e);
    fprintf(stderr, "X2V_RESIDENT clip_end codec=dng frames=%u dropped=%u lost=%u proxy=%u seconds=%.2f "
            "write_ms_max=%u (open %u close %u) pack_ms_max=%u error=%d %s\n", written, atomic_load(&S.dropped),
            atomic_load(&S.lost), v.frames, secs, atomic_load(&S.write_ms_max), atomic_load(&D.open_ms_max),
            atomic_load(&D.close_ms_max), atomic_load(&D.pack_ms_max), e, st);
    char tl[DNG_TRACE * 40];
    size_t o = 0;
    for (uint32_t i = 0; i < DNG_TRACE && i < written && o < sizeof tl; i++) {
        const struct dng_trace *r = &D.tr[i];
        int w = snprintf(tl + o, sizeof tl - o, " %u:%u/%u/%u/%u/%u/%u", i, r->copy, r->start, r->pack, r->open,
                         r->data, r->close);
        if (w < 0) break;
        o += (size_t)w;
    }
    tl[o < sizeof tl ? o : sizeof tl - 1] = 0;
    fprintf(stderr, "X2V_RESIDENT dng_trace proxy_begin=%u i:copy/start/pack/open/data/close%s\n",
            D.proxy_begin_ms, tl);
    arm_proxy();
}

static void end_clip(unsigned seq)
{
    if (S.mode == MODE_H264) { end_h264(); return; }
    if (S.mode == MODE_DNG) { end_dng(seq); return; }
    atomic_store(&S.state, ST_FINALIZING);
    atomic_store(&S.recording, 0);
    while (atomic_load(&S.in_flight)) usleep(1000);
    pthread_mutex_lock(&S.mu);
    S.flushing = 1;
    pthread_cond_broadcast(&S.cv);
    pthread_mutex_unlock(&S.mu);
    uint64_t limit = now_ns() + 20000000000ull;
    for (;;) {
        pthread_mutex_lock(&S.mu);
        int done = drained();
        pthread_mutex_unlock(&S.mu);
        if (done || now_ns() > limit) break;
        write_status(seq);
        usleep(20000);
    }
    double secs = (double)(now_ns() - S.clip_begin_ns) / 1e9;
    pthread_mutex_lock(&S.mu);
    int e = drained() ? 0 : ETIMEDOUT;
    uint64_t from = S.ring_out, to = S.ring_in;
    int direct = S.direct;
    if (!e) {
        int failed = from < to && ring_write(S.mov.fd, from, to);
        S.ring_out = to;
        retire_frames(to, failed);
    }
    S.mov_open = 0;
    S.flushing = 0;
    pthread_cond_broadcast(&S.cv);
    /* After a timeout what is left will not be written; a write in progress still owns dfd. */
    if (e) retire_frames(UINT64_MAX, 1);
    while (S.writer_busy) pthread_cond_wait(&S.cv, &S.mu);
    if (e) S.ring_out = S.ring_in;
    pthread_mutex_unlock(&S.mu);
    if (S.dfd >= 0) close(S.dfd);
    S.dfd = -1;
    if (prr_mov_close(&S.mov) && !e) e = EIO;
    if (!e && syscall(SYS_renameat2, S.dirfd, "clip.partial.mov", S.dirfd, "clip.mov", 1u)) e = errno;
    uint32_t written = atomic_load(&S.written);
    char j[1024], st[192];
    int n = snprintf(j, sizeof j,
        "{\"schema\":1,\"format\":\"ProRes RAW\",\"fourcc\":\"aprn\",\"width\":%d,\"height\":%d,\"fps\":25,"
        "\"frames\":%u,\"dropped\":%u,\"lost\":%u,\"seen\":%u,\"bytes\":%llu,\"seconds\":%.3f,"
        "\"duration\":%.3f,\"source_span_raw\":%llu,\"queue_max\":%llu,\"write_ms_max\":%u,\"direct\":%d,"
        "\"wb\":[%.4f,%.4f],%s,\"error\":%d}\n",
        PRR_W, PRR_H, written, atomic_load(&S.dropped), atomic_load(&S.lost), atomic_load(&S.seen),
        (unsigned long long)atomic_load(&S.bytes), secs, written / 25.0,
        (unsigned long long)(atomic_load(&S.last_ts) - atomic_load(&S.first_ts)), (unsigned long long)S.qbytes_max,
        atomic_load(&S.write_ms_max), direct, clip_meta.wb_red, clip_meta.wb_blue, stall_json(st, sizeof st), e);
    finish_clip(j, n, written, atomic_load(&S.dropped), secs, e);
    fprintf(stderr, "X2V_RESIDENT clip_end frames=%u dropped=%u lost=%u seconds=%.2f error=%d %s\n",
            written, S.last_dropped, atomic_load(&S.lost), secs, e, st);
}

static void write_file(const char *path, const void *p, size_t n)
{
    int fd = open(path, O_WRONLY | O_CREAT | O_TRUNC | O_CLOEXEC, 0644);
    if (fd < 0) return;
    if (write(fd, p, n) != (ssize_t)n) fprintf(stderr, "X2V_RESIDENT short_write %s\n", path);
    close(fd);
}

static void colour_dump_files(int raw)
{
    cdump_raw = raw;
    atomic_store(&cdump, 1);
    for (int i = 0; i < 200 && (atomic_load(&cdump) == 1 || atomic_load(&cdump) == 4); i++) usleep(10000);
    int st = atomic_load(&cdump);
    if (st == 2) {
        write_file(LIVE_DIR "/colour.desc", cdump_desc, sizeof cdump_desc);
        write_file(LIVE_DIR "/colour_a.nv12", cdump_buf[0], cdump_size);
        write_file(LIVE_DIR "/colour_b.nv12", cdump_buf[1], cdump_size);
    }
    fprintf(stderr, "X2V_RESIDENT cdump state=%d size=%u\n", st, cdump_size);
    if (st == 2 || st == 3) {
        for (int i = 0; i < 2; i++) { free(cdump_buf[i]); cdump_buf[i] = NULL; }
        atomic_store(&cdump, 0);
    }
}

static void colour_pair_files(void)
{
    if (atomic_load(&cpair) == 4) return;
    if (!cpair_pre) cpair_pre = malloc(PV_BYTES);
    if (!cpair_post) cpair_post = malloc(PV_BYTES);
    if (!cpair_pre || !cpair_post) return;
    if (atomic_load(&cpair) != 2) {
        atomic_store(&cpair, 1);
        for (int i = 0; i < 200 && atomic_load(&cpair) != 2; i++) usleep(10000);
    }
    if (atomic_load(&cpair) != 2) {
        int armed = 1;
        atomic_compare_exchange_strong(&cpair, &armed, 0);
        fprintf(stderr, "X2V_RESIDENT cpair timeout state=%d\n", atomic_load(&cpair));
        return;
    }
    write_file(LIVE_DIR "/pair_pre.nv12", cpair_pre, PV_BYTES);
    write_file(LIVE_DIR "/pair_post.nv12", cpair_post, PV_BYTES);
    write_file(LIVE_DIR "/pair.desc", cpair_desc, sizeof cpair_desc);
    write_file(LIVE_DIR "/pair_gains.bin", &cpair_gains, sizeof cpair_gains);
    char j[512];
    int n = snprintf(j, sizeof j,
        "{\"schema\":1,\"callback_ordinal\":%u,\"begin_ns\":%llu,\"end_ns\":%llu,"
        "\"width\":%d,\"height\":%d,\"stride\":%d,\"bytes\":%d,"
        "\"same_callback\":true,\"hardware_frame_id_verified\":false}\n",
        cpair_ordinal, (unsigned long long)cpair_begin_ns, (unsigned long long)cpair_end_ns,
        PV_W, PV_H, PV_STRIDE, PV_BYTES);
    write_file(LIVE_DIR "/pair.json", j, n);
    atomic_store(&cpair, 0);
}

static const char *token(const char *p, char *out, size_t cap)
{
    while (*p == ' ' || *p == '\t') p++;
    size_t n = 0;
    while (*p && *p != ' ' && *p != '\t' && *p != '\n' && *p != '\r') {
        if (n + 1 >= cap) return NULL;
        out[n++] = *p++;
    }
    out[n] = 0;
    return p;
}

/* "<seq> <verb> [arg [arg2]]"; returns nonzero when malformed. */
static int parse_command(const char *cmd, unsigned *seq, char *verb, size_t vcap, char *arg, size_t acap,
                         char *arg2, size_t a2cap)
{
    char num[16];
    const char *p = token(cmd, num, sizeof num);
    if (!p || !num[0]) return 1;
    for (const char *c = num; *c; c++) if (*c < '0' || *c > '9') return 1;
    *seq = (unsigned)strtoul(num, NULL, 10);
    if (!(p = token(p, verb, vcap)) || !verb[0]) return 1;
    if (!(p = token(p, arg, acap))) return 1;
    return token(p, arg2, a2cap) ? 0 : 1;
}

static void *control_thread(void *unused)
{
    pthread_setname_np(pthread_self(), "x2v-ctl");
    (void)unused;
    unsigned last_seq = 0, ack = 0;
    char cmd[512];
    uint64_t next_status = 0;
    int fd = open(LIVE_DIR "/command", O_RDONLY | O_CLOEXEC);
    if (fd >= 0) {
        ssize_t n = read(fd, cmd, sizeof cmd - 1);
        close(fd);
        if (n > 0) { cmd[n] = 0; last_seq = (unsigned)strtoul(cmd, NULL, 10); ack = last_seq; }
    }
    for (;;) {
        fd = open(LIVE_DIR "/command", O_RDONLY | O_CLOEXEC);
        if (fd >= 0) {
            ssize_t n = read(fd, cmd, sizeof cmd - 1);
            close(fd);
            unsigned seq = 0;
            char verb[16] = "", arg[300] = "", arg2[16] = "";
            if (n > 0) {
                cmd[n] = 0;
                if (parse_command(cmd, &seq, verb, sizeof verb, arg, sizeof arg, arg2, sizeof arg2)) seq = last_seq;
            }
            if (n > 0 && seq != last_seq) {
                last_seq = seq;
                int st = atomic_load(&S.state);
                if (!strcmp(verb, "rec") && (st == ST_IDLE || st == ST_ERROR)) {
                    int mode = !strcmp(arg2, "h264") ? MODE_H264 : !strcmp(arg2, "dng") ? MODE_DNG : MODE_PRR;
                    int e = arg2[0] && mode == MODE_PRR && strcmp(arg2, "prores_raw") ? EINVAL : begin_clip(arg, mode);
                    if (e) { S.error = e; atomic_store(&S.state, ST_ERROR); }
                    fprintf(stderr, "X2V_RESIDENT rec dir=%s codec=%s rc=%d\n", arg, mode_name[mode], e);
                } else if (!strcmp(verb, "prep") && st == ST_IDLE) {
                    int pe = 0; /* AF idle trial: encoder opens on actual record. */
                    /* AF investigation uses ProRes RAW. Keep the four extra DNG
                     * slots lazy; begin_dng() still prepares them when requested. */
                    int de = 0;
                    fprintf(stderr, "X2V_RESIDENT prep rc=%d dng=%d\n", pe, de);
                    if (getenv("X2V_PREWARM_H264")) arm_proxy();
                } else if (!strcmp(verb, "cdump")) {
                    colour_dump_files(!strcmp(arg, "raw"));
                } else if (!strcmp(verb, "cpair") && st == ST_IDLE) {
                    colour_pair_files();
                } else if (!strcmp(verb, "release")) {
                    atomic_store(&released, 1);
                    fprintf(stderr, "X2V_RESIDENT release guard_absorbed=%u\n", x2v_session_guard_absorbed());
                } else if (!strcmp(verb, "stop") && st == ST_RECORDING) {
                    end_clip(seq);
                } else if (!strcmp(verb, "quit")) {
                    atomic_store(&released, 1);
                    if (st == ST_RECORDING) end_clip(seq);
                    vrec_disarm();
                    ack = seq;
                    write_status(ack);
                    return NULL;
                }
                ack = seq;
                write_status(ack);
            }
        }
        uint64_t t = now_ns();
        if (t >= next_status) { write_status(ack); next_status = t + 100000000ull; }
        usleep(20000);
    }
    return NULL;
}

/* CPU-only setup. The msenc DSP is not ready while camera-service boots, so the
 * encoder is opened later by ensure_encoder(): on "prep" once the graph runs, or
 * failing that on the first clip. */
static void *startup_thread(void *unused)
{
    pthread_setname_np(pthread_self(), "x2v-start");
    (void)unused;
    static const struct prr_pre_geom geom = PRR_PRE_GEOM_MODE21;
    int e = prr_pre_init(&pre, &geom, SENSOR_WHITE, 0.0f, 1) ? ENOMEM : 0;
    pthread_t th;
    for (int i = 1; !e && i < POOL_PARTS; i++)
        e = pthread_create(&th, NULL, pool_worker, (void *)(intptr_t)i);
    /* Serves every RAW clip; it touches the encoder only for ProRes RAW, which first needs ensure_encoder(). */
    if (!e && sem_init(&enc_jobs, 0, 0)) e = errno;
    if (!e) e = pthread_create(&th, NULL, encode_thread, NULL);
    S.error = e;
    atomic_store(&S.state, e ? ST_ERROR : ST_IDLE);
    fprintf(stderr, "X2V_RESIDENT cpu_ready rc=%d\n", e);
    write_status(0);
    return NULL;
}

__attribute__((constructor)) static void setup(void)
{
    const char *t = getenv("X2V_RESIDENT");
    if (!t || strcmp(t, RESIDENT_TOKEN)) return;
    int e = hook_bind();
    mkdir(LIVE_DIR, 0755);
    for (int i = 0; !e && i < BASE_SLOTS; i++)
        if (posix_memalign((void **)&S.slot[i].data, 4096, X2V_BYTES)) e = ENOMEM;
    for (int i = BASE_SLOTS; i < SRC_SLOTS; i++) atomic_store(&S.slot[i].state, SLOT_ABSENT);
    S.pv_rgb = malloc(32 + (size_t)PVR_W * PVR_H * 3);
    S.pvr_rows[0] = malloc(sizeof *S.pvr_rows[0]);
    S.pvr_rows[1] = malloc(sizeof *S.pvr_rows[1]);
    if (!S.pv_rgb || !S.pvr_rows[0] || !S.pvr_rows[1]) e = ENOMEM;
    const char *v = getenv("X2V_ISP_VIEW");
    isp_view = v && !strcmp(v, "1");
    pthread_t th;
    if (!e) e = pthread_create(&th, NULL, preview_thread, NULL);
    /* Without the helper the preview renders whole frames on its own thread. */
    if (!e && !pthread_create(&th, NULL, preview_helper, NULL)) PH.ready = 1;
    if (!e) e = pthread_create(&th, NULL, control_thread, NULL);
    if (!e) e = pthread_create(&th, NULL, startup_thread, NULL);
    if (e) { S.error = e; atomic_store(&S.state, ST_ERROR); write_status(0); }
    else enabled = 1;
    fprintf(stderr, "X2V_RESIDENT setup rc=%d token=" RESIDENT_TOKEN "\n", e);
}

int x2v_af_recording(void){return atomic_load(&S.recording);}
