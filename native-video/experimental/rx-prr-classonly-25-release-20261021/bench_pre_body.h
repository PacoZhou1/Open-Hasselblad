/* Shared body of bench_pre / bench_preold: the PRR preprocess over a MODE21 frame, one thread and
 * split four ways like the resident pool, alone and against a competing copier. */
#include <pthread.h>
#include <stdatomic.h>
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

static const struct prr_pre_geom G = PRR_PRE_GEOM_MODE21;
static struct prr_pre P;
static uint16_t *src, *dst;
static _Atomic int stop;

struct part { int lo, hi; };

static void *part_run(void *v)
{
    struct part *p = v;
    prr_pre_rows(&P, src, dst, 4096.0f, p->lo, p->hi);
    return NULL;
}

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

static void round_of(const char *label, int rounds)
{
    uint64_t one = ~0ull, four = ~0ull, one_sum = 0, four_sum = 0;
    for (int r = 0; r < rounds; r++) {
        uint64_t t = now_us();
        prr_pre_rows(&P, src, dst, 4096.0f, 0, G.height);
        t = now_us() - t;
        one_sum += t;
        if (t < one) one = t;
        struct part parts[4];
        pthread_t th[4];
        t = now_us();
        for (int i = 0; i < 4; i++) {
            parts[i] = (struct part){G.height * i / 4, G.height * (i + 1) / 4};
            if (i) pthread_create(&th[i], NULL, part_run, &parts[i]);
        }
        part_run(&parts[0]);
        for (int i = 1; i < 4; i++) pthread_join(th[i], NULL);
        t = now_us() - t;
        four_sum += t;
        if (t < four) four = t;
    }
    printf("%s one-thread best %.1f mean %.1f ms | four-way best %.1f mean %.1f ms\n", label, one / 1e3,
           one_sum / 1e3 / rounds, four / 1e3, four_sum / 1e3 / rounds);
}

int main(int argc, char **argv)
{
    int rounds = argc > 1 ? atoi(argv[1]) : 20;
    if (prr_pre_init(&P, &G, 64681.0f, 0.0f, 1)) return 1;
    size_t n = (size_t)G.src_stride_px * G.src_rows;
    src = malloc(n * 2);
    dst = malloc((size_t)G.dst_stride_px * G.height * 2);
    if (!src || !dst) return 1;
    for (size_t i = 0; i < n; i++) src[i] = (uint16_t)(4096 + ((i * 2654435761u) >> 20) % 20000);
    memset(dst, 0, (size_t)G.dst_stride_px * G.height * 2);
    round_of(BENCH_NAME " alone", rounds);
    pthread_t c;
    pthread_create(&c, NULL, copier, NULL);
    round_of(BENCH_NAME " copier", rounds);
    atomic_store(&stop, 1);
    pthread_join(c, NULL);
    return 0;
}
