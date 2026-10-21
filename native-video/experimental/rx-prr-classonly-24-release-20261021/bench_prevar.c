/* On-camera: where the PD-row interpolation's time goes. One-thread MODE21 preprocess, variants
 * interleaved round by round: plain (no class fix), up-only, down-only, both, both + prefetch.
 * Usage: bench_prevar [rounds] */
#include "prr_pre.h"
#include <arm_neon.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

static uint64_t now_us(void)
{
    struct timespec t;
    clock_gettime(CLOCK_MONOTONIC, &t);
    return (uint64_t)t.tv_sec * 1000000 + (uint64_t)t.tv_nsec / 1000;
}

static inline uint16x8_t lin8(uint16x8_t v, uint16x4_t g, uint32x4_t off)
{
    uint32x4_t lo = vqsubq_u32(vmull_u16(vget_low_u16(v), g), off);
    uint32x4_t hi = vqsubq_u32(vmull_u16(vget_high_u16(v), g), off);
    return vqrshrn_high_n_u32(vqrshrn_n_u32(lo, 15), hi, 15);
}

static const struct prr_pre_geom G = PRR_PRE_GEOM_MODE21;

static void run(int variant, const uint16_t *src, uint16_t *dst, int pf)
{
    uint16x4_t g = vdup_n_u16(30000);
    uint32x4_t off = vdupq_n_u32(4096u * 30000u);
    static const uint16_t odd[8] = {0, 0xffff, 0, 0xffff, 0, 0xffff, 0, 0xffff};
    uint16x8_t sel = vld1q_u16(odd);
    const size_t two = 2 * (size_t)G.src_stride_px;
    for (int r = 0; r < G.height; r++) {
        const uint16_t *s = src + (size_t)(G.y0 + r) * G.src_stride_px + G.x0;
        uint16_t *d = dst + (size_t)r * G.dst_stride_px;
        if (variant == 0 || (G.y0 + r) % 6 != 1) {
            for (int x = 0; x < G.width; x += 8)
                vst1q_u16(d + x, lin8(vld1q_u16(s + x), g, off));
            continue;
        }
        for (int x = 0; x < G.width; x += 8) {
            if (pf > 0) {
                __builtin_prefetch(s + x + two + pf);
                __builtin_prefetch(s + x - two + pf);
            } else if (pf < 0) {
                __builtin_prefetch(s + x + two - pf);
            }
            uint16x8_t m;
            if (variant == 1) m = vld1q_u16(s + x - two);
            else if (variant == 2) m = vld1q_u16(s + x + two);
            else if (variant == 4) {
                __builtin_prefetch(s + x + pf);
                m = vrhaddq_u16(vld1q_u16(s + x - two), vld1q_u16(s + x + two));
            } else m = vrhaddq_u16(vld1q_u16(s + x - two), vld1q_u16(s + x + two));
            vst1q_u16(d + x, lin8(vbslq_u16(sel, m, vld1q_u16(s + x)), g, off));
        }
    }
}

int main(int argc, char **argv)
{
    int rounds = argc > 1 ? atoi(argv[1]) : 10;
    size_t n = (size_t)G.src_stride_px * G.src_rows;
    uint16_t *src = malloc(n * 2), *dst = malloc((size_t)G.dst_stride_px * G.height * 2);
    if (!src || !dst) return 1;
    for (size_t i = 0; i < n; i++) src[i] = (uint16_t)(4096 + ((i * 2654435761u) >> 20) % 20000);
    memset(dst, 0, (size_t)G.dst_stride_px * G.height * 2);
    static const char *name[] = {"plain", "both", "pf128B", "pf256B", "pf512B", "dn-pf256B", "dn-pf512B", "pf+s256B"};
    static const int var[] = {0, 3, 3, 3, 3, 3, 3, 4}, pf[] = {0, 0, 64, 128, 256, -128, -256, 128};
    uint64_t best[8], sum[8];
    for (int v = 0; v < 8; v++) best[v] = ~0ull, sum[v] = 0;
    for (int r = 0; r < rounds; r++)
        for (int v = 0; v < 8; v++) {
            uint64_t t = now_us();
            run(var[v], src, dst, pf[v]);
            __asm__ volatile("" ::"r"(dst), "r"(src) : "memory");
            t = now_us() - t;
            sum[v] += t;
            if (t < best[v]) best[v] = t;
        }
    for (int v = 0; v < 8; v++)
        printf("%-12s best %5.1f mean %5.1f ms\n", name[v], best[v] / 1e3, sum[v] / 1e3 / rounds);
    return 0;
}
