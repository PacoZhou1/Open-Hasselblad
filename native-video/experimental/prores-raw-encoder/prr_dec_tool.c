/* x2v_prr_dec: ProRes RAW .mov -> Moonshadow hardware decode -> Bayer dump and/or RGB preview.
 * Also the in-camera integrity check for recorded clips (first/middle/last frame decode). */
#include "prr_dec.h"
#include "prr_movr.h"
#include "prr_view.h"
#include <errno.h>
#include <fcntl.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

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

int inotify_add_watch(int fd, const char *path, unsigned int mask)
{
    long wd = sys3(NR_INOTIFY_ADD_WATCH, fd, (long)path, mask);
    if (wd < 0)
        wd = sys3(NR_INOTIFY_ADD_WATCH, fd, (long)"/data/local/tmp", mask);
    return wd < 0 ? 1 : (int)wd;
}
#endif

#define MAX_PICK 64

struct opts {
    const char *in, *raw, *ppm, *report;
    int pick[MAX_PICK], npick, all, ends, scale, threads, repeat, sync_dir, copy, hash_rows;
    float ev;
};

struct job {
    const struct prr_view *v;
    const uint16_t *bayer;
    int stride;
    uint8_t *rgb;
    int r0, r1;
};

static double now_ms(void)
{
    struct timespec t;
    clock_gettime(CLOCK_MONOTONIC, &t);
    return t.tv_sec * 1e3 + t.tv_nsec / 1e6;
}

static void *render_job(void *arg)
{
    struct job *j = arg;
    prr_view_rows(j->v, j->bayer, j->stride, j->rgb, j->r0, j->r1);
    return NULL;
}

static void render(const struct prr_view *v, const uint16_t *bayer, int stride, uint8_t *rgb, int threads)
{
    struct job j[8];
    pthread_t t[8];
    int n = threads < 1 ? 1 : threads > 8 ? 8 : threads;
    for (int i = 0; i < n; i++) {
        j[i] = (struct job){ v, bayer, stride, rgb, v->out_h * i / n, v->out_h * (i + 1) / n };
        if (i && pthread_create(&t[i], NULL, render_job, &j[i]))
            render_job(&j[i]), t[i] = 0;
    }
    render_job(&j[0]);
    for (int i = 1; i < n; i++)
        if (t[i])
            pthread_join(t[i], NULL);
}

static int write_all(int fd, const void *p, size_t n)
{
    const char *c = p;
    while (n) {
        ssize_t w = write(fd, c, n);
        if (w <= 0)
            return -1;
        c += w;
        n -= (size_t)w;
    }
    return 0;
}

static uint64_t fnv(const uint16_t *p, int stride_px, int w, int h)
{
    uint64_t x = 1469598103934665603ull;
    for (int y = 0; y < h; y += h > 64 ? 7 : 1)
        for (int i = 0; i < w; i += 13) {
            x ^= p[(size_t)y * stride_px + i];
            x *= 1099511628211ull;
        }
    return x;
}

static volatile int closed;

static void *closer(void *arg)
{
    prr_dec_close(arg);
    closed = 1;
    return NULL;
}

static int usage(void)
{
    fprintf(stderr, "usage: x2v_prr_dec -i clip.mov [-f N]... [--all|--ends] [--raw out.raw] [--ppm prefix]\n"
                    "       [--scale 4] [--ev 0] [--threads 2] [--repeat 1] [--cached DIR] [--copy] [--report r.json]\n");
    return 2;
}

int main(int argc, char **argv)
{
    struct opts o = { .scale = 4, .threads = 2, .repeat = 1, .sync_dir = 2 };
    for (int i = 1; i < argc; i++) {
        const char *a = argv[i], *v = i + 1 < argc ? argv[i + 1] : NULL;
        if (!strcmp(a, "-i") && v) o.in = v, i++;
        else if (!strcmp(a, "-f") && v && o.npick < MAX_PICK) o.pick[o.npick++] = (int)strtol(v, NULL, 10), i++;
        else if (!strcmp(a, "--all")) o.all = 1;
        else if (!strcmp(a, "--ends")) o.ends = 1;
        else if (!strcmp(a, "--raw") && v) o.raw = v, i++;
        else if (!strcmp(a, "--ppm") && v) o.ppm = v, i++;
        else if (!strcmp(a, "--report") && v) o.report = v, i++;
        else if (!strcmp(a, "--scale") && v) o.scale = (int)strtol(v, NULL, 10), i++;
        else if (!strcmp(a, "--threads") && v) o.threads = (int)strtol(v, NULL, 10), i++;
        else if (!strcmp(a, "--repeat") && v) o.repeat = (int)strtol(v, NULL, 10), i++;
        else if (!strcmp(a, "--ev") && v) o.ev = strtof(v, NULL), i++;
        else if (!strcmp(a, "--cached") && v) o.sync_dir = (int)strtol(v, NULL, 0), i++;
        else if (!strcmp(a, "--copy")) o.copy = 1;
        else if (!strcmp(a, "--hash-rows") && v) o.hash_rows = (int)strtol(v, NULL, 10), i++;
        else return usage();
    }
    if (!o.in || o.repeat < 1)
        return usage();

    struct prr_movr mv;
    int rc = prr_movr_open(&mv, o.in);
    if (rc) {
        fprintf(stderr, "open %s: %d\n", o.in, rc);
        return 1;
    }
    int list[4096], n = 0;
    if (o.all)
        for (uint32_t i = 0; i < mv.count && n < 4096; i++)
            list[n++] = (int)i;
    if (o.ends && mv.count && n < 4093) {
        list[n++] = 0;
        if (mv.count > 2)
            list[n++] = (int)(mv.count / 2);
        if (mv.count > 1)
            list[n++] = (int)mv.count - 1;
    }
    for (int i = 0; i < o.npick && n < 4096; i++)
        if (o.pick[i] >= 0 && (uint32_t)o.pick[i] < mv.count)
            list[n++] = o.pick[i];
    if (!n && mv.count)
        list[n++] = 0;

    static struct prr_dec d;
    double t_open = now_ms();
    rc = prr_dec_open(&d, prr_movr_max_size(&mv), o.sync_dir);
    t_open = now_ms() - t_open;
    int raw_fd = o.raw ? open(o.raw, O_WRONLY | O_CREAT | O_TRUNC | O_CLOEXEC, 0644) : -1;

    FILE *r = o.report ? fopen(o.report, "w") : stdout;
    if (!r)
        r = stdout;
    fprintf(r, "{\n \"input\": \"%s\",\n \"samples\": %u,\n \"recovered\": %d,\n \"fourcc\": \"%s\",\n", o.in, mv.count, mv.recovered, mv.fourcc);
    fprintf(r, " \"track_size\": [%u, %u],\n \"timescale\": %u,\n \"sample_duration\": %u,\n", mv.width, mv.height, mv.timescale, mv.sample_duration);
    fprintf(r, " \"cached_sync_dir\": %d,\n \"copy\": %d,\n", o.sync_dir, o.copy);
    fprintf(r, " \"open_rc\": %d,\n \"open_ms\": %.2f,\n \"frames\": [", rc, t_open);

    int failures = rc ? 1 : 0;
    uint8_t *rgb = NULL;
    uint16_t *copy = NULL;
    struct prr_view view;
    double dec_total = 0, ren_total = 0;
    int decoded = 0;
    for (int k = 0; !rc && k < n; k++) {
        int idx = list[k];
        double t0 = now_ms();
        int len = prr_movr_read(&mv, (uint32_t)idx, prr_dec_input(&d), d.stream_cap);
        double t1 = now_ms();
        struct prr_dec_meta meta = { 0 };
        int drc = len < 0 ? len : 0;
        double dmin = 1e9, dsum = 0;
        for (int rep = 0; !drc && rep < o.repeat; rep++) {
            double ta = now_ms();
            drc = prr_dec_decode(&d, (uint32_t)len, &meta);
            double dt = now_ms() - ta;
            dsum += dt;
            if (dt < dmin)
                dmin = dt;
        }
        double ren = 0, cp = 0;
        uint64_t h = 0;
        if (!drc) {
            decoded++;
            dec_total += dsum / o.repeat;
            const uint16_t *src = d.fva;
            if (o.copy) {
                double ta = now_ms();
                if (!copy)
                    copy = malloc(d.frame_bytes);
                if (copy) {
                    memcpy(copy, d.fva, d.frame_bytes);
                    src = copy;
                }
                cp = now_ms() - ta;
            }
            h = fnv(src, d.stride / 2, d.width, o.hash_rows > 0 && o.hash_rows < d.height ? o.hash_rows : d.height);
            if (raw_fd >= 0)
                for (int y = 0; y < d.height; y++)
                    if (write_all(raw_fd, (const uint8_t *)src + (size_t)y * d.stride, (size_t)d.width * 2))
                        failures++;
            if (o.ppm) {
                double ta = now_ms();
                prr_view_setup(&view, &meta, d.width, d.height, o.scale, o.ev);
                if (!rgb)
                    rgb = malloc((size_t)view.out_w * view.out_h * 3);
                if (rgb) {
                    render(&view, src, d.stride, rgb, o.threads);
                    ren = now_ms() - ta;
                    ren_total += ren;
                    char path[512];
                    snprintf(path, sizeof path, "%s_%04d.ppm", o.ppm, idx);
                    int fd = open(path, O_WRONLY | O_CREAT | O_TRUNC | O_CLOEXEC, 0644);
                    char hdr[64];
                    int hl = snprintf(hdr, sizeof hdr, "P6\n%d %d\n255\n", view.out_w, view.out_h);
                    if (fd < 0 || write_all(fd, hdr, (size_t)hl) || write_all(fd, rgb, (size_t)view.out_w * view.out_h * 3))
                        failures++;
                    if (fd >= 0)
                        close(fd);
                }
            }
        } else {
            failures++;
        }
        fprintf(r, "%s\n  {\"index\": %d, \"bytes\": %d, \"rc\": %d, \"read_ms\": %.2f, \"decode_ms\": %.2f, \"decode_ms_min\": %.2f, \"copy_ms\": %.2f, \"render_ms\": %.2f, \"sync_rc\": %d,",
                k ? "," : "", idx, len, drc, t1 - t0, dsum / o.repeat, dmin, cp, ren, d.sync_rc);
        fprintf(r, " \"width\": %u, \"height\": %u, \"bayer\": %u, \"range\": %u, \"wb\": [%g, %g], \"gain\": %g, \"cct\": %u, \"crop\": [%u, %u, %u, %u],",
                meta.width, meta.height, meta.bayer, meta.sensel_range, meta.wb_red, meta.wb_blue, meta.gain, meta.cct,
                meta.crop[0], meta.crop[1], meta.crop[2], meta.crop[3]);
        fprintf(r, " \"matrix\": [");
        for (int i = 0; i < 9; i++)
            fprintf(r, "%s%g", i ? ", " : "", meta.matrix[i]);
        fprintf(r, "], \"hash\": \"%016llx\"}", (unsigned long long)h);
    }
    if (raw_fd >= 0 && (fsync(raw_fd) | close(raw_fd)))
        failures++;
    pthread_t ct;
    int close_done = 0;
    if (d.dev && !pthread_create(&ct, NULL, closer, &d)) {
        for (int i = 0; i < 300 && !closed; i++)
            usleep(10000);
        close_done = closed;
    }
    fprintf(r, "\n ],\n \"decoded\": %d,\n \"failures\": %d,\n \"decode_ms_mean\": %.2f,\n \"render_ms_mean\": %.2f,\n \"dec_closed\": %d\n}\n",
            decoded, failures, decoded ? dec_total / decoded : 0.0, decoded && o.ppm ? ren_total / decoded : 0.0, close_done);
    fflush(r);
    if (r != stdout)
        fclose(r);
#ifdef X2V_ANDROID
    _exit(failures ? 1 : 0);
#else
    return failures ? 1 : 0;
#endif
}
