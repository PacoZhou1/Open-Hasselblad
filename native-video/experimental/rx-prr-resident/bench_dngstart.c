/* On-camera: the opening second of a DNG clip's writes, without the camera. A new directory,
 * frames arriving at 24 fps into 7 slots, 3 writers each creating one O_DIRECT file per frame
 * (pixels at 4096, then the header at 0), as the resident does.
 *   bench_dngstart <parent> <frames> [warm_kib]
 * warm_kib > 0: first create, write (O_DIRECT, warm_kib), close and unlink one file in the new
 * directory. Prints the warm-up, the steps of the first frames, and the frames no slot took. */
#include <errno.h>
#include <fcntl.h>
#include <pthread.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <time.h>
#include <unistd.h>

#define SLOTS 7
#define WRITERS 3
#define PIXELS ((size_t)3968 * 2944 * 3 / 2)
#define HDR 4096
#define TRACE 32

static uint64_t now_ms(void)
{
    struct timespec t;
    clock_gettime(CLOCK_MONOTONIC, &t);
    return (uint64_t)t.tv_sec * 1000 + (uint64_t)t.tv_nsec / 1000000;
}

static pthread_mutex_t mu = PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t cv = PTHREAD_COND_INITIALIZER;
static int q[64], qh, qn, busy, done_feeding, dirfd_ = -1;
static uint8_t *buf;
static uint64_t t0;
static struct { uint32_t arrive, start, open, data, close; } tr[TRACE];

static void *writer(void *unused)
{
    (void)unused;
    for (;;) {
        pthread_mutex_lock(&mu);
        while (!qn && !done_feeding) pthread_cond_wait(&cv, &mu);
        if (!qn) { pthread_mutex_unlock(&mu); return NULL; }
        int i = q[qh];
        qh = (qh + 1) % 64;
        qn--;
        pthread_mutex_unlock(&mu);
        char name[64];
        snprintf(name, sizeof name, "f_%06d.dng", i);
        uint64_t a = now_ms();
        int fd = openat(dirfd_, name, O_WRONLY | O_CREAT | O_TRUNC | O_CLOEXEC | O_DIRECT, 0644);
        uint64_t b = now_ms();
        if (fd >= 0) {
            if (pwrite(fd, buf, PIXELS, HDR) != (ssize_t)PIXELS || pwrite(fd, buf, HDR, 0) != HDR) printf("write %d: %s\n", i, strerror(errno));
        } else printf("open %d: %s\n", i, strerror(errno));
        uint64_t c = now_ms();
        if (fd >= 0) close(fd);
        uint64_t e = now_ms();
        if (i < TRACE) {
            tr[i].start = (uint32_t)(a - t0);
            tr[i].open = (uint32_t)(b - a);
            tr[i].data = (uint32_t)(c - b);
            tr[i].close = (uint32_t)(e - c);
        }
        pthread_mutex_lock(&mu);
        busy--;
        pthread_cond_broadcast(&cv);
        pthread_mutex_unlock(&mu);
    }
}

int main(int argc, char **argv)
{
    if (argc < 3) return 2;
    int frames = atoi(argv[2]), warm = argc > 3 ? atoi(argv[3]) : 0;
    char dir[256];
    snprintf(dir, sizeof dir, "%s/bench_dngstart_%ld", argv[1], (long)time(NULL));
    if (posix_memalign((void **)&buf, 4096, PIXELS)) return 1;
    memset(buf, 0x5a, PIXELS);
    uint64_t m0 = now_ms();
    if (mkdir(dir, 0755)) { printf("mkdir: %s\n", strerror(errno)); return 1; }
    dirfd_ = open(dir, O_RDONLY | O_DIRECTORY | O_CLOEXEC);
    uint64_t m1 = now_ms();
    printf("mkdir+open %llu ms\n", (unsigned long long)(m1 - m0));
    if (warm > 0) {
        uint64_t w0 = now_ms();
        int fd = openat(dirfd_, ".warm", O_WRONLY | O_CREAT | O_TRUNC | O_CLOEXEC | O_DIRECT, 0644);
        uint64_t w1 = now_ms();
        size_t n = (size_t)warm << 10;
        if (fd >= 0 && pwrite(fd, buf, n > PIXELS ? PIXELS : n, 0) < 0) printf("warm write: %s\n", strerror(errno));
        uint64_t w2 = now_ms();
        if (fd >= 0) close(fd);
        unlinkat(dirfd_, ".warm", 0);
        uint64_t w3 = now_ms();
        printf("warm: open %llu write %llu close+unlink %llu ms\n", (unsigned long long)(w1 - w0),
               (unsigned long long)(w2 - w1), (unsigned long long)(w3 - w2));
    }
    pthread_t th[WRITERS];
    for (int i = 0; i < WRITERS; i++) pthread_create(&th[i], NULL, writer, NULL);
    t0 = now_ms();
    int dropped = 0, first_drop = -1;
    for (int i = 0; i < frames; i++) {
        uint64_t due = t0 + (uint64_t)i * 1000 / 24;
        while (now_ms() < due) usleep(1000);
        pthread_mutex_lock(&mu);
        if (busy >= SLOTS) {
            dropped++;
            if (first_drop < 0) first_drop = i;
        } else {
            busy++;
            q[(qh + qn) % 64] = i;
            qn++;
            pthread_cond_signal(&cv);
        }
        pthread_mutex_unlock(&mu);
    }
    pthread_mutex_lock(&mu);
    done_feeding = 1;
    pthread_cond_broadcast(&cv);
    pthread_mutex_unlock(&mu);
    for (int i = 0; i < WRITERS; i++) pthread_join(th[i], NULL);
    printf("frames %d dropped %d (first %d) in %llu ms\n i:start/open/data/close", frames, dropped, first_drop,
           (unsigned long long)(now_ms() - t0));
    for (int i = 0; i < TRACE && i < frames; i++)
        printf(" %d:%u/%u/%u/%u", i, tr[i].start, tr[i].open, tr[i].data, tr[i].close);
    printf("\n%s\n", dir);
    return 0;
}
