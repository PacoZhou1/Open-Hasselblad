/* x2v_prr_enc: camera MODE21 raw frames -> Moonshadow ProRes RAW encoder -> QuickTime.
 * Runs from adb su (the factory shell cannot exec from /data). */
#include "prr_enc.h"
#include "prr_mov.h"
#include "prr_pre.h"
#include <errno.h>
#include <fcntl.h>
#include <math.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

#define HDR_WB_RED 0x1c
#define HDR_MATRIX 0x24
#define HDR_GAIN 0x48
#define HDR_CCT 0x4c
#define HDR_COLOUR_END 0x4e

#ifdef X2V_ANDROID
#define NR_INOTIFY_ADD_WATCH 27

static long sys3(long nr, long a, long b, long c)
{
    register long x8 __asm__("x8") = nr;
    register long x0 __asm__("x0") = a;
    register long x1 __asm__("x1") = b;
    register long x2 __asm__("x2") = c;
    __asm__ volatile("svc #0" : "+r"(x0) : "r"(x8), "r"(x1), "r"(x2) : "memory");
    return x0;
}

/* The codec debug hub asserts when adb su is denied an inotify watch on its directories; a denied
 * watch is redirected to a directory su may watch so inotify_rm_watch still yields IN_IGNORED. */
int inotify_add_watch(int fd, const char *path, unsigned int mask)
{
    long wd = sys3(NR_INOTIFY_ADD_WATCH, fd, (long)path, mask);
    if (wd < 0)
        wd = sys3(NR_INOTIFY_ADD_WATCH, fd, (long)"/data/local/tmp", mask);
    return wd < 0 ? 1 : (int)wd;
}
#endif

struct opts {
    const char *in, *out, *bin, *report;
    int frames, preload, threads, banding, patch, profile, plugin_open, frame_slots, stream_slots, cached_stream;
    float black, white, ob_bias;
    uint32_t timescale, duration;
    struct prr_meta meta;
    int have_meta;
};

struct work {
    const struct prr_pre *pre;
    const uint16_t *src;
    uint16_t *dst;
    float black;
    int r0, r1;
};

static double now_ms(void)
{
    struct timespec t;
    clock_gettime(CLOCK_MONOTONIC, &t);
    return t.tv_sec * 1e3 + t.tv_nsec / 1e6;
}

static void *run_rows(void *arg)
{
    struct work *w = arg;
    prr_pre_rows(w->pre, w->src, w->dst, w->black, w->r0, w->r1);
    return NULL;
}

static void preprocess(const struct prr_pre *pre, const uint16_t *src, uint16_t *dst, float black, int threads)
{
    struct work w[8];
    pthread_t t[8];
    int h = pre->g.height;
    for (int i = 0; i < threads; i++)
        w[i] = (struct work){ pre, src, dst, black, h * i / threads, h * (i + 1) / threads };
    for (int i = 1; i < threads; i++)
        if (pthread_create(&t[i], NULL, run_rows, &w[i]))
            run_rows(&w[i]), t[i] = 0;
    run_rows(&w[0]);
    for (int i = 1; i < threads; i++)
        if (t[i])
            pthread_join(t[i], NULL);
}

static uint32_t rd32(const uint8_t *p) { return (uint32_t)p[0] << 24 | p[1] << 16 | p[2] << 8 | p[3]; }

static void wr32(uint8_t *p, uint32_t v) { p[0] = v >> 24; p[1] = v >> 16; p[2] = v >> 8; p[3] = v; }

static uint32_t fbits(float f) { uint32_t u; memcpy(&u, &f, 4); return u; }

static float bitsf(uint32_t u) { float f; memcpy(&f, &u, 4); return f; }

static void colour_bytes(const struct prr_meta *m, uint8_t out[HDR_COLOUR_END - HDR_WB_RED])
{
    uint8_t *p = out;
    wr32(p, fbits(m->wb_red));
    wr32(p + 4, fbits(m->wb_blue));
    for (int i = 0; i < 9; i++)
        wr32(p + 8 + 4 * i, fbits(m->matrix[i]));
    wr32(p + HDR_GAIN - HDR_WB_RED, fbits(m->gain));
    p[HDR_CCT - HDR_WB_RED] = m->cct >> 8;
    p[HDR_CCT - HDR_WB_RED + 1] = (uint8_t)m->cct;
}

static int parse_floats(const char *s, float *v, int n)
{
    for (int i = 0; i < n; i++) {
        char *end;
        v[i] = strtof(s, &end);
        if (end == s)
            return -1;
        s = *end == ',' ? end + 1 : end;
    }
    return 0;
}

static void usage(void)
{
    fprintf(stderr,
            "x2v_prr_enc -i frames.raw [-o out.mov] [--bin out.prr] [--report r.json] [-n frames]\n"
            "  [--preload 6] [--threads 2] [--black auto|N] [--white 64681] [--ob-bias -3] [--no-banding]\n"
            "  [--fps 24|25|30|23.976] [--profile 1] [--plugin-open] [--slots F,S] [--no-patch] [--cached-stream]\n"
            "  [--meta wb_red,wb_blue,gain,cct,m0..m8]\n");
}

static int parse(int argc, char **argv, struct opts *o)
{
    *o = (struct opts){ .frames = -1, .preload = 6, .threads = 2, .banding = 1, .patch = 1, .profile = 1,
                        .frame_slots = 3, .stream_slots = 3, .black = NAN, .white = 64681.0f, .ob_bias = -3.0f,
                        .timescale = 24000, .duration = 1000 };
    for (int i = 1; i < argc; i++) {
        const char *a = argv[i];
        const char *v = i + 1 < argc ? argv[i + 1] : NULL;
#define TAKE (v ? (i++, v) : (usage(), exit(2), v))
        if (!strcmp(a, "-i")) o->in = TAKE;
        else if (!strcmp(a, "-o")) o->out = TAKE;
        else if (!strcmp(a, "--bin")) o->bin = TAKE;
        else if (!strcmp(a, "--report")) o->report = TAKE;
        else if (!strcmp(a, "-n")) o->frames = atoi(TAKE);
        else if (!strcmp(a, "--preload")) o->preload = atoi(TAKE);
        else if (!strcmp(a, "--threads")) o->threads = atoi(TAKE);
        else if (!strcmp(a, "--black")) { const char *b = TAKE; o->black = strcmp(b, "auto") ? strtof(b, NULL) : NAN; }
        else if (!strcmp(a, "--white")) o->white = strtof(TAKE, NULL);
        else if (!strcmp(a, "--ob-bias")) o->ob_bias = strtof(TAKE, NULL);
        else if (!strcmp(a, "--no-banding")) o->banding = 0;
        else if (!strcmp(a, "--no-patch")) o->patch = 0;
        else if (!strcmp(a, "--plugin-open")) o->plugin_open = 1;
        else if (!strcmp(a, "--cached-stream")) o->cached_stream = 1;
        else if (!strcmp(a, "--profile")) o->profile = atoi(TAKE);
        else if (!strcmp(a, "--slots")) {
            char *end;
            o->frame_slots = (int)strtol(TAKE, &end, 10);
            if (*end != ',')
                return usage(), -1;
            o->stream_slots = (int)strtol(end + 1, NULL, 10);
        }
        else if (!strcmp(a, "--fps")) {
            const char *f = TAKE;
            if (!strcmp(f, "23.976")) { o->timescale = 24000; o->duration = 1001; }
            else { o->timescale = (uint32_t)atoi(f) * 1000; o->duration = 1000; }
        } else if (!strcmp(a, "--meta")) {
            float v13[13];
            if (parse_floats(TAKE, v13, 13))
                return -1;
            o->meta.wb_red = v13[0];
            o->meta.wb_blue = v13[1];
            o->meta.gain = v13[2];
            o->meta.cct = (uint16_t)lrintf(v13[3]);
            memcpy(o->meta.matrix, v13 + 4, sizeof o->meta.matrix);
            o->have_meta = 1;
        } else {
            usage();
            return -1;
        }
#undef TAKE
    }
    if (!o->in || o->threads < 1 || o->threads > 8 || o->preload < 1)
        return usage(), -1;
    return 0;
}

int main(int argc, char **argv)
{
    struct opts o;
    if (parse(argc, argv, &o))
        return 2;
    static const struct prr_pre_geom geom = PRR_PRE_GEOM_MODE21;
    struct prr_pre pre;
    if (prr_pre_init(&pre, &geom, o.white, o.ob_bias, o.banding)) {
        fprintf(stderr, "prr_pre_init failed\n");
        return 1;
    }
    size_t src_bytes = (size_t)geom.src_stride_px * geom.src_rows * 2;
    FILE *in = fopen(o.in, "rb");
    if (!in) {
        perror(o.in);
        return 1;
    }
    uint16_t **src = calloc((size_t)o.preload, sizeof *src);
    int loaded = 0;
    while (loaded < o.preload) {
        src[loaded] = malloc(src_bytes);
        if (!src[loaded] || fread(src[loaded], 1, src_bytes, in) != src_bytes) {
            free(src[loaded]);
            break;
        }
        loaded++;
    }
    fclose(in);
    if (!loaded) {
        fprintf(stderr, "no complete frame in %s\n", o.in);
        return 1;
    }
    int frames = o.frames < 0 ? loaded : o.frames;

    struct prr_enc_cfg cfg = { geom.width, geom.height, geom.dst_stride_px * 2, o.profile, 0,
                               o.frame_slots, o.stream_slots, o.plugin_open, o.cached_stream, 0 };
    static struct prr_enc enc;
    int rc = prr_enc_open(&enc, &cfg);
    if (rc) {
        fprintf(stderr, "prr_enc_open failed %d\n", rc);
        prr_enc_close_timed(&enc, 3000);
        _exit(1);
    }
    struct prr_mov mov;
    int mov_ok = o.out ? prr_mov_open(&mov, o.out, geom.width, geom.height, o.profile ? "aprh" : "aprn", o.timescale, o.duration) == 0 : 0;
    int bin_fd = o.bin ? open(o.bin, O_WRONLY | O_CREAT | O_TRUNC | O_CLOEXEC, 0644) : -1;
    if ((o.out && !mov_ok) || (o.bin && bin_fd < 0)) {
        fprintf(stderr, "cannot open output\n");
        prr_enc_close_timed(&enc, 3000);
        _exit(1);
    }

    uint8_t want[HDR_COLOUR_END - HDR_WB_RED];
    colour_bytes(&o.meta, want);
    uint8_t first_header[0x98] = { 0 };
    float *blacks = calloc((size_t)frames, sizeof *blacks);
    uint64_t total_bytes = 0;
    uint32_t written = 0, bad_frames = 0, hal_meta_match = 0, patched = 0, write_errors = 0, max_bytes = 0, min_bytes = UINT32_MAX;
    double t_pre = 0, t_pre_max = 0, t_write = 0, t_write_max = 0, t_wait = 0;
    double t0 = now_ms();

    int submitted = 0, slot = -1;
    while (written < (uint32_t)frames) {
        if (submitted < frames && slot < 0) {
            double tw = now_ms();
            uint16_t *dst;
            slot = prr_enc_acquire_frame(&enc, &dst);
            if (slot < 0) {
                fprintf(stderr, "no free frame slot\n");
                break;
            }
            const uint16_t *s = src[submitted % loaded];
            float black = isnan(o.black) ? prr_pre_black(&pre, s) : o.black;
            blacks[submitted] = black;
            double tp = now_ms();
            t_wait += tp - tw;
            preprocess(&pre, s, dst, black, o.threads);
            double dp = now_ms() - tp;
            t_pre += dp;
            if (dp > t_pre_max)
                t_pre_max = dp;
        }
        if (slot >= 0) {
            uint64_t pts = (uint64_t)submitted * o.duration * 1000000ull / o.timescale;
            rc = prr_enc_submit(&enc, slot, pts, o.have_meta ? &o.meta : NULL);
            if (!rc) {
                submitted++;
                slot = -1;
            } else if (rc != -EAGAIN) {
                fprintf(stderr, "submit failed %d at frame %d\n", rc, submitted);
                break;
            }
        }
        struct prr_out out;
        int timeout = slot >= 0 || submitted == frames ? 3000 : 0;
        if (prr_enc_next(&enc, &out, timeout) != 0) {
            if (!timeout)
                continue;
            fprintf(stderr, "timeout waiting for frame %u\n", written);
            break;
        }
        uint32_t size = out.alen + out.blen;
        uint8_t *a = (uint8_t *)out.a;
        int ok = out.alen >= 0x98 && rd32(a) == size && !memcmp(a + 4, "prrf", 4);
        if (!ok) {
            bad_frames++;
        } else {
            if (!written)
                memcpy(first_header, a, sizeof first_header);
            if (!memcmp(a + HDR_WB_RED, want, sizeof want))
                hal_meta_match++;
            else if (o.patch && o.have_meta) {
                memcpy(a + HDR_WB_RED, want, sizeof want);
                patched++;
            }
            double tw = now_ms();
            if (mov_ok && prr_mov_write(&mov, out.a, out.alen, out.b, out.blen))
                write_errors++;
            if (bin_fd >= 0 && (write(bin_fd, out.a, out.alen) != (ssize_t)out.alen ||
                                (out.blen && write(bin_fd, out.b, out.blen) != (ssize_t)out.blen)))
                write_errors++;
            double dw = now_ms() - tw;
            t_write += dw;
            if (dw > t_write_max)
                t_write_max = dw;
            total_bytes += size;
            if (size > max_bytes)
                max_bytes = size;
            if (size < min_bytes)
                min_bytes = size;
        }
        prr_enc_release(&enc, &out);
        written++;
    }
    double elapsed = now_ms() - t0;

    int close_rc = 0;
    if (mov_ok)
        close_rc |= prr_mov_close(&mov);
    if (bin_fd >= 0)
        close_rc |= fsync(bin_fd) | close(bin_fd);
    int close_step = prr_enc_close_timed(&enc, 3000);

    FILE *r = o.report ? fopen(o.report, "w") : stdout;
    if (!r)
        r = stdout;
    fprintf(r, "{\n \"frames_requested\": %d,\n \"frames_loaded\": %d,\n \"submitted\": %d,\n \"written\": %u,\n", frames, loaded, submitted, written);
    fprintf(r, " \"bad_frames\": %u,\n \"write_errors\": %u,\n \"close_rc\": %d,\n \"enc_close_step\": %d,\n", bad_frames, write_errors, close_rc, close_step);
    fprintf(r, " \"hal_busy_returns\": %u,\n \"unknown_callbacks\": %u,\n \"hal_encoded\": %u,\n", enc.busy_returns, enc.unknown_callbacks, enc.encoded);
    fprintf(r, " \"meta_given\": %d,\n \"header_meta_from_hal\": %u,\n \"header_meta_patched\": %u,\n", o.have_meta, hal_meta_match, patched);
    fprintf(r, " \"profile\": %d,\n \"plugin_open\": %d,\n \"banding\": %d,\n \"threads\": %d,\n \"cached_stream\": %d,\n", o.profile, o.plugin_open, o.banding, o.threads, o.cached_stream);
    fprintf(r, " \"bytes_total\": %llu,\n \"bytes_min\": %u,\n \"bytes_max\": %u,\n", (unsigned long long)total_bytes, written ? min_bytes : 0, max_bytes);
    fprintf(r, " \"elapsed_ms\": %.1f,\n \"fps\": %.2f,\n", elapsed, elapsed > 0 ? written * 1000.0 / elapsed : 0.0);
    fprintf(r, " \"preprocess_ms_mean\": %.2f,\n \"preprocess_ms_max\": %.2f,\n", submitted ? t_pre / submitted : 0.0, t_pre_max);
    fprintf(r, " \"write_ms_mean\": %.2f,\n \"write_ms_max\": %.2f,\n \"slot_wait_ms_total\": %.1f,\n", written ? t_write / written : 0.0, t_write_max, t_wait);
    fprintf(r, " \"first_header_hex\": \"");
    for (size_t i = 0; i < sizeof first_header; i++)
        fprintf(r, "%02x", first_header[i]);
    fprintf(r, "\",\n \"first_header_colour\": {\"wb_red\": %g, \"wb_blue\": %g, \"gain\": %g, \"cct\": %u},\n",
            bitsf(rd32(first_header + HDR_WB_RED)), bitsf(rd32(first_header + HDR_WB_RED + 4)),
            bitsf(rd32(first_header + HDR_GAIN)), (unsigned)(first_header[HDR_CCT] << 8 | first_header[HDR_CCT + 1]));
    fprintf(r, " \"black\": [");
    for (int i = 0; i < submitted; i++)
        fprintf(r, "%s%.2f", i ? ", " : "", blacks[i]);
    fprintf(r, "]\n}\n");
    fflush(r);
    if (r != stdout)
        fclose(r);
    int ok = written == (uint32_t)frames && !bad_frames && !write_errors && !close_rc;
#ifdef X2V_ANDROID
    _exit(ok ? 0 : 1);
#else
    return ok ? 0 : 1;
#endif
}
