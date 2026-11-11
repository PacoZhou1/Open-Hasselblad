/* Read-only, opt-in diagnostics for firmware 1.3.16.2. Native callbacks and
 * results are forwarded unchanged. This does not seed, tune or drive AF. */
#define _GNU_SOURCE 1
#include <dlfcn.h>
#include <stdatomic.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

extern void *__loader_dlsym(void *, const char *, const void *);
static _Atomic unsigned bfm_count, bfm_frame;

static int enabled(void) {
    const char *s = getenv("X2V_AF_DIAGNOSTICS");
    return s && !strcmp(s, "1");
}
static void *original(const char *name) {
    void *h = dlopen("/system/lib64/libaaa.so", RTLD_NOW | RTLD_NOLOAD);
    return h ? __loader_dlsym(h, name, (void *)&original) : NULL;
}
static uint64_t ns(void) {
    struct timespec t;
    clock_gettime(CLOCK_MONOTONIC, &t);
    return (uint64_t)t.tv_sec * 1000000000ull + (unsigned)t.tv_nsec;
}

int af_scene_bfm_set_stats(int ch, const void *stats) {
    typedef int (*Fn)(int, const void *);
    static Fn real;
    if (!real) { void *p = original("af_scene_bfm_set_stats"); memcpy(&real, &p, sizeof real); }
    if (!real) return -1;
    int rc = real(ch, stats);
    if (!ch && stats && enabled()) {
        uint32_t words[5];
        /* The native callee itself reads the 16-byte header and frame at +16. */
        memcpy(words, stats, sizeof words);
        unsigned n = atomic_fetch_add(&bfm_count, 1) + 1;
        atomic_store(&bfm_frame, words[4]);
        if (n <= 2 || !(n % 96))
            fprintf(stderr, "X2V_AF_BFM mono=%llu n=%u header=%x,%x,%x,%x frame=%u rc=%d\n",
                    (unsigned long long)ns(), n, words[0], words[1], words[2], words[3], words[4], rc);
    }
    return rc;
}

int dcam_af_set_stat(int ch, const void *stats) {
    typedef int (*Fn)(int, const void *);
    static Fn real;
    static _Atomic unsigned count[32];
    static _Atomic uint32_t tag[32];
    if (!real) { void *p = original("dcam_af_set_stat"); memcpy(&real, &p, sizeof real); }
    if (!real) return -1;
    int rc = real(ch, stats);
    if (!ch && stats && enabled()) {
        uint32_t h[4]; memcpy(h, stats, sizeof h);
        unsigned slot;
        for (slot=0;slot<32;++slot) {
            uint32_t empty=0;
            if (atomic_load(&tag[slot])==h[0] ||
                atomic_compare_exchange_strong(&tag[slot],&empty,h[0])) break;
        }
        if (slot==32) return rc;
        unsigned n = atomic_fetch_add(&count[slot], 1) + 1;
        if (n <= 2 || !(n % 240))
            fprintf(stderr, "X2V_AF_STAT mono=%llu n=%u header=%x,%x,%x,%x rc=%d\n",
                    (unsigned long long)ns(), n, h[0], h[1], h[2], h[3], rc);
    }
    return rc;
}

void x2v_af_roi_diagnostics(int ch) {
    if (ch || !enabled()) return;
    static uint64_t last;
    uint64_t now = ns();
    if (now - last < 250000000ull) return;
    last = now;
    typedef int (*GetInt)(int);
    typedef void (*GetRoi)(int, void *);
    static const char *names[] = {"af_get_frame_id", "af_smart_roi_available",
        "af_get_current_smart_roi_mode", "af_get_arbitrary_status", "af_get_is_afc_trigger",
        "lens_ctrl_get_cur_focus_pos", "tof_get_output_conf", "tof_get_output_peak"};
    static GetInt ints[8];
    static const char *roi_names[] = {"af_get_alg_roi", "af_get_tof_tracking_roi", "af_get_vdaf_tracking_roi"};
    static GetRoi rois[3];
    int values[8] = {0}; uint32_t regions[3][6] = {{0}};
    for (unsigned i=0; i<8; ++i) {
        if (!ints[i]) { void *p=original(names[i]); memcpy(&ints[i], &p, sizeof p); }
        if (ints[i]) values[i]=ints[i](ch);
    }
    for (unsigned i=0; i<3; ++i) {
        if (!rois[i]) { void *p=original(roi_names[i]); memcpy(&rois[i], &p, sizeof p); }
        /* Matching ELF getters copy exactly 24 bytes, without mutating state. */
        if (rois[i]) rois[i](ch, regions[i]);
    }
    fprintf(stderr,"X2V_AF_ROI mono=%llu frame=%d smart=%d mode=%d arbitrary=%d trigger=%d lens=%d conf=%d peak=%d bfm_count=%u bfm_frame=%u",
        (unsigned long long)now,values[0],values[1],values[2],values[3],values[4],values[5],values[6],values[7],
        atomic_load(&bfm_count),atomic_load(&bfm_frame));
    for (unsigned i=0;i<3;++i) {
        fprintf(stderr," %s=",roi_names[i]);
        for (unsigned j=0;j<6;++j) fprintf(stderr,"%s%08x",j?",":"",regions[i][j]);
    }
    fputc('\n',stderr);
}
