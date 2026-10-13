/* x2v_prr_proxy: ProRes RAW .mov -> hardware decode -> NV12 -> stock test_venc_e2 -> playback.mp4 */
#include "prr_dec.h"
#include "prr_movr.h"
#include "prr_view.h"
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <unistd.h>

#define PW 1024
#define PH 768
#define MAX_FRAMES 240

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
        wd = sys3(NR_INOTIFY_ADD_WATCH, fd, (long)"/tmp", mask);
    return wd < 0 ? 1 : (int)wd;
}
#endif

static void rgb_to_nv12(const uint8_t *rgb, int sw, int sh, uint8_t *nv, int dw, int dh)
{
    int ox = (dw - sw) / 2, oy = (dh - sh) / 2;
    memset(nv, 16, (size_t)dw * dh);
    memset(nv + (size_t)dw * dh, 128, (size_t)dw * dh / 2);
    for (int y = 0; y < sh; y++) {
        const uint8_t *s = rgb + (size_t)y * sw * 3;
        uint8_t *yd = nv + (size_t)(y + oy) * dw + ox;
        for (int x = 0; x < sw; x++) {
            int r = s[x * 3], g = s[x * 3 + 1], b = s[x * 3 + 2];
            int Y = (77 * r + 150 * g + 29 * b + 128) >> 8;
            yd[x] = (uint8_t)(Y < 0 ? 0 : Y > 255 ? 255 : Y);
        }
    }
    for (int y = 0; y < sh; y += 2) {
        const uint8_t *s0 = rgb + (size_t)y * sw * 3;
        const uint8_t *s1 = rgb + (size_t)(y + 1 < sh ? y + 1 : y) * sw * 3;
        uint8_t *uv = nv + (size_t)dw * dh + (size_t)((y + oy) / 2) * dw + (ox & ~1);
        for (int x = 0; x < sw; x += 2) {
            int r = (s0[x * 3] + s0[(x + 1) * 3] + s1[x * 3] + s1[(x + 1) * 3]) / 4;
            int g = (s0[x * 3 + 1] + s0[(x + 1) * 3 + 1] + s1[x * 3 + 1] + s1[(x + 1) * 3 + 1]) / 4;
            int b = (s0[x * 3 + 2] + s0[(x + 1) * 3 + 2] + s1[x * 3 + 2] + s1[(x + 1) * 3 + 2]) / 4;
            int U = ((-43 * r - 85 * g + 128 * b + 128) >> 8) + 128;
            int V = ((128 * r - 107 * g - 21 * b + 128) >> 8) + 128;
            uv[x] = (uint8_t)(U < 0 ? 0 : U > 255 ? 255 : U);
            uv[x + 1] = (uint8_t)(V < 0 ? 0 : V > 255 ? 255 : V);
        }
    }
}

static int write_all(int fd, const void *p, size_t n)
{
    const uint8_t *c = p;
    while (n) {
        ssize_t w = write(fd, c, n);
        if (w <= 0)
            return -1;
        c += (size_t)w;
        n -= (size_t)w;
    }
    return 0;
}

static int write_config(const char *path, const char *yuv, const char *out, int frames)
{
    FILE *f = fopen(path, "w");
    if (!f)
        return -1;
    int n = fprintf(f,
        "{\n \"instance_active_num\":1,\n \"enable_perf_trace\":0,\n \"instances\":[{\n"
        "  \"input\":\"%s\",\n  \"output\":\"%s\",\n  \"recon\":\"\",\n  \"gmv\":\"\",\n"
        "  \"src_width\":%d,\n  \"src_height\":%d,\n  \"enc_width\":%d,\n  \"enc_height\":%d,\n"
        "  \"frame_rate_num\":24,\n  \"frame_rate_den\":1,\n  \"bitrate\":4000000,\n"
        "  \"input_alignment\":8,\n  \"input_bitdepth\":8,\n  \"codec_type\":\"HEVC\",\n"
        "  \"input_format\":\"NV12\",\n  \"enc_mode\":\"storage\",\n  \"enc_pic_num\":%d,\n"
        "  \"hw_core_num\":1,\n  \"priority\":0,\n  \"aging\":0,\n  \"force_i_enc\":0,\n"
        "  \"enable_performance_test\":0,\n  \"enable_bandwidth_test\":0,\n"
        "  \"enable_dynamic_frame_rate_test\":0,\n  \"enable_debug_dump_test\":0,\n"
        "  \"enable_force_idr_test\":0,\n  \"enable_re_encode_test\":0,\n"
        "  \"enable_custom_ref_test\":0,\n  \"idr_interval\":0\n }]}\n",
        yuv, out, PW, PH, PW, PH, frames);
    int e = n <= 0 || fclose(f);
    return e ? -1 : 0;
}

static int run_venc(const char *venc, const char *cfg, const char *preload)
{
    pid_t pid = fork();
    if (pid < 0)
        return -1;
    if (!pid) {
        if (preload && *preload)
            setenv("LD_PRELOAD", preload, 1);
        execl(venc, venc, cfg, (char *)0);
        _exit(127);
    }
    int st = 0;
    if (waitpid(pid, &st, 0) != pid)
        return -1;
    return WIFEXITED(st) ? WEXITSTATUS(st) : -1;
}

int main(int argc, char **argv)
{
    const char *in = NULL, *out = NULL, *work = "/data/x2v-prr-proxy";
    const char *venc = "/system/bin/test_venc_e2";
    const char *preload = "";
    int scale = 4, max_frames = MAX_FRAMES;
    for (int i = 1; i < argc; i++) {
        const char *a = argv[i], *v = i + 1 < argc ? argv[i + 1] : NULL;
        if (!strcmp(a, "-i") && v) in = v, i++;
        else if (!strcmp(a, "-o") && v) out = v, i++;
        else if (!strcmp(a, "--work") && v) work = v, i++;
        else if (!strcmp(a, "--venc") && v) venc = v, i++;
        else if (!strcmp(a, "--preload") && v) preload = v, i++;
        else if (!strcmp(a, "--scale") && v) scale = (int)strtol(v, NULL, 10), i++;
        else if (!strcmp(a, "--max") && v) max_frames = (int)strtol(v, NULL, 10), i++;
        else {
            fprintf(stderr, "usage: x2v_prr_proxy -i clip.mov -o playback.mp4 [--work DIR]\n");
            return 2;
        }
    }
    if (!in || !out || scale < 2 || (scale & 1) || max_frames < 1)
        return 2;

    struct prr_movr mv;
    int rc = prr_movr_open(&mv, in);
    if (rc) {
        fprintf(stderr, "mov_open %d\n", rc);
        return 1;
    }
    uint32_t n = mv.count;
    if (n > (uint32_t)max_frames)
        n = (uint32_t)max_frames;
    if (n < 2) {
        fprintf(stderr, "need >=2 samples, have %u\n", mv.count);
        prr_movr_close(&mv);
        return 1;
    }

    if (mkdir(work, 0700) && errno != EEXIST) {
        fprintf(stderr, "mkdir %s: %d\n", work, errno);
        prr_movr_close(&mv);
        return 1;
    }
    char yuv[256], cfg[256], tmpout[256];
    snprintf(yuv, sizeof yuv, "%s/proxy.nv12", work);
    snprintf(cfg, sizeof cfg, "%s/venc.json", work);
    snprintf(tmpout, sizeof tmpout, "%s/proxy.mp4", work);
    unlink(yuv);
    unlink(tmpout);

    static struct prr_dec dec;
    rc = prr_dec_open(&dec, prr_movr_max_size(&mv), 2);
    if (rc) {
        fprintf(stderr, "dec_open %d\n", rc);
        prr_movr_close(&mv);
        return 1;
    }

    int yfd = open(yuv, O_WRONLY | O_CREAT | O_TRUNC | O_CLOEXEC, 0600);
    uint8_t *rgb = NULL, *nv = NULL;
    int released = 0;
    size_t nv_bytes = (size_t)PW * PH * 3 / 2;
    nv = malloc(nv_bytes);
    if (yfd < 0 || !nv) {
        rc = ENOMEM;
        goto done;
    }

    unsigned encoded = 0;
    for (uint32_t i = 0; i < n; i++) {
        int len = prr_movr_read(&mv, i, prr_dec_input(&dec), dec.stream_cap);
        struct prr_dec_meta meta = { 0 };
        if (len < 0 || prr_dec_decode(&dec, (uint32_t)len, &meta)) {
            fprintf(stderr, "decode %u failed\n", i);
            rc = EIO;
            break;
        }
        struct prr_view view;
        prr_view_setup(&view, &meta, dec.width, dec.height, scale, 0);
        if (view.out_w > PW || view.out_h > PH || view.out_w < 16 || view.out_h < 16) {
            fprintf(stderr, "view %dx%d does not fit %dx%d\n", view.out_w, view.out_h, PW, PH);
            rc = EOVERFLOW;
            break;
        }
        size_t rgb_bytes = (size_t)view.out_w * view.out_h * 3;
        uint8_t *nrgb = realloc(rgb, rgb_bytes);
        if (!nrgb) {
            rc = ENOMEM;
            break;
        }
        rgb = nrgb;
        prr_view_rows(&view, dec.fva, dec.stride, rgb, 0, view.out_h);
        rgb_to_nv12(rgb, view.out_w, view.out_h, nv, PW, PH);
        if (write_all(yfd, nv, nv_bytes)) {
            rc = EIO;
            break;
        }
        encoded++;
    }
    if (yfd >= 0)
        close(yfd);
    yfd = -1;
    /* Close Moonshadow before test_venc_e2: venc calls duss_hal_deinitialize
     * and a later msdec close deadlocks on the destroyed objects.lock. */
    prr_dec_close(&dec);
    prr_movr_close(&mv);
    released = 1;
    if (rc || encoded < 2)
        goto done;

    if (write_config(cfg, yuv, tmpout, (int)encoded)) {
        rc = EIO;
        goto done;
    }
    int venc_rc = run_venc(venc, cfg, preload);
    struct stat st;
    if (venc_rc || stat(tmpout, &st) || !S_ISREG(st.st_mode) || st.st_size < 64) {
        fprintf(stderr, "venc rc=%d size=%lld\n", venc_rc, (long long)(stat(tmpout, &st) ? -1 : st.st_size));
        rc = EIO;
        goto done;
    }
    if (rename(tmpout, out) && (unlink(out), rename(tmpout, out))) {
        rc = errno ? errno : EIO;
        goto done;
    }
    printf("{\"ok\":true,\"frames\":%u,\"width\":%d,\"height\":%d,\"bytes\":%lld,\"source_samples\":%u}\n",
           encoded, PW, PH, (long long)st.st_size, mv.count);
    rc = 0;

done:
    free(rgb);
    free(nv);
    if (yfd >= 0)
        close(yfd);
    if (!released) {
        prr_dec_close(&dec);
        prr_movr_close(&mv);
    }
    return rc ? 1 : 0;
}
