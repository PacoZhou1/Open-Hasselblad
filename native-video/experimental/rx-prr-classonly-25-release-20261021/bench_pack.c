/* On-camera: the DNG slot filled by a plain copy of the MODE21 frame vs packed to 12 bits
 * on the way, alone and against a competing copier (a writer's pass over another frame).
 * Usage: bench_pack [rounds] */
#include "dng.c"
#include <pthread.h>
#include <stdatomic.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define FRAME ((size_t)3968 * 2 * 2946)
#define SAMPLES ((size_t)3968 * 2944)

static uint64_t now_us(void)
{
    struct timespec t;
    clock_gettime(CLOCK_MONOTONIC, &t);
    return (uint64_t)t.tv_sec * 1000000 + (uint64_t)t.tv_nsec / 1000;
}

static _Atomic int stop;

/* 8 MB each way: far past the caches, small beside the camera's own memory. */
#define COPIER ((size_t)8 << 20)

static void *copier(void *unused)
{
    (void)unused;
    uint8_t *a = malloc(COPIER), *b = malloc(COPIER);
    if (!a || !b) return NULL;
    memset(a, 1, COPIER);
    memset(b, 2, COPIER);
    while (!atomic_load(&stop)) memcpy(b, a, COPIER);
    free(a);
    free(b);
    return NULL;
}

static int cmp(const void *a, const void *b) { return (int)(*(const uint64_t *)a - *(const uint64_t *)b); }

static void run(const char *label, uint16_t *src, uint8_t *dst, int rounds)
{
    uint64_t c[64], p[64];
    for (int i = 0; i < rounds; i++) {
        uint64_t t = now_us();
        memcpy(dst, src, FRAME);
        c[i] = now_us() - t;
        t = now_us();
        dng_pack12_to(dst, src, SAMPLES);
        p[i] = now_us() - t;
    }
    qsort(c, (size_t)rounds, sizeof *c, cmp);
    qsort(p, (size_t)rounds, sizeof *p, cmp);
    printf("%s: copy ms min %.1f med %.1f max %.1f | pack ms min %.1f med %.1f max %.1f\n", label, c[0] / 1e3,
           c[rounds / 2] / 1e3, c[rounds - 1] / 1e3, p[0] / 1e3, p[rounds / 2] / 1e3, p[rounds - 1] / 1e3);
}

int main(int argc, char **argv)
{
    int rounds = argc > 1 ? atoi(argv[1]) : 12;
    if (rounds < 1 || rounds > 64) rounds = 12;
    uint16_t *src = malloc(FRAME);
    uint8_t *dst = malloc(FRAME);
    if (!src || !dst) return 1;
    for (size_t i = 0; i < FRAME / 2; i++) src[i] = (uint16_t)((i * 2654435761u >> 8) & 0xfff0);
    memset(dst, 0, FRAME);
    run("alone", src, dst, rounds);
    pthread_t th[2];
    pthread_create(&th[0], NULL, copier, NULL);
    run("1 copier", src, dst, rounds);
    pthread_create(&th[1], NULL, copier, NULL);
    run("2 copiers", src, dst, rounds);
    atomic_store(&stop, 1);
    pthread_join(th[0], NULL);
    pthread_join(th[1], NULL);
    return 0;
}
