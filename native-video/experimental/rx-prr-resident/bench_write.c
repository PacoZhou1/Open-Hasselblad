/* On-camera sustained write rate of the clip volume:
 *   bench_write <file> <mode> [MiB] [chunk_MiB] [lag]
 * mode: buffered | behind (start writeback per chunk, wait + drop the chunk `lag` behind) | direct (O_DIRECT)
 * Writes frame-sized 8 MiB blocks from one reused buffer, fsyncs, prints MB/s and the slowest write. */
#include <errno.h>
#include <fcntl.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

static uint64_t now_us(void)
{
    struct timespec t;
    clock_gettime(CLOCK_MONOTONIC, &t);
    return (uint64_t)t.tv_sec * 1000000u + (uint64_t)t.tv_nsec / 1000u;
}

int main(int argc, char **argv)
{
    if (argc < 3) return 2;
    const char *mode = argv[2];
    uint64_t total = (uint64_t)(argc > 3 ? atoi(argv[3]) : 1024) << 20;
    uint64_t chunk = (uint64_t)(argc > 4 ? atoi(argv[4]) : 8) << 20;
    int lag = argc > 5 ? atoi(argv[5]) : 1;
    const size_t block = 8u << 20;
    int direct = !strcmp(mode, "direct"), behind = !strcmp(mode, "behind");
    int fd = open(argv[1], O_WRONLY | O_CREAT | O_TRUNC | O_CLOEXEC | (direct ? O_DIRECT : 0), 0644);
    if (fd < 0) { printf("open: %s\n", strerror(errno)); return 1; }
    void *buf;
    if (posix_memalign(&buf, 4096, block)) return 1;
    for (size_t i = 0; i < block; i++) ((uint8_t *)buf)[i] = (uint8_t)(i * 2654435761u >> 13);
    uint64_t pos = 0, started = 0, done = 0, t0 = now_us(), worst = 0;
    while (pos < total) {
        uint64_t t = now_us();
        ssize_t w = write(fd, buf, block);
        if (w != (ssize_t)block) { printf("write: %zd %s\n", w, strerror(errno)); return 1; }
        pos += block;
        if (behind && pos - started >= chunk) {
            sync_file_range(fd, (off_t)started, (off_t)(pos - started), SYNC_FILE_RANGE_WRITE);
            if (started >= done + chunk * (uint64_t)lag) {
                uint64_t end = started - chunk * (uint64_t)(lag - 1);
                sync_file_range(fd, (off_t)done, (off_t)(end - done),
                                SYNC_FILE_RANGE_WAIT_BEFORE | SYNC_FILE_RANGE_WRITE | SYNC_FILE_RANGE_WAIT_AFTER);
                posix_fadvise(fd, (off_t)done, (off_t)(end - done), POSIX_FADV_DONTNEED);
                done = end;
            }
            started = pos;
        }
        uint64_t d = now_us() - t;
        if (d > worst) worst = d;
    }
    uint64_t t1 = now_us();
    fsync(fd);
    uint64_t t2 = now_us();
    close(fd);
    printf("%s chunk=%lluM lag=%d: %.0f MB/s to page cache/device, %.0f MB/s incl fsync, worst write %llu ms\n", mode,
           (unsigned long long)(chunk >> 20), lag, total / (double)(t1 - t0), total / (double)(t2 - t0),
           (unsigned long long)(worst / 1000));
    return 0;
}
