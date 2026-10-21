/* Host test of vrec's stream side: a real camera Annex-B stream arrives through a pipe in random
 * chunks; the reader must cut exactly the first <frames> access units into a playable MOV whose
 * durations follow the fed timestamps.
 * usage: test_vrec in.h264 out_dir frames gap_at */
#ifdef __APPLE__
#include <pthread.h>
#define POSIX_SPAWN_USEVFORK 0
#define F_SETPIPE_SZ 1031
#define pthread_setname_np(t, n) pthread_setname_np(n)
#endif
#include "vrec.c"
#include <assert.h>

int duss_hal_mem_get_size(void *h, uint32_t *s) { (void)h; (void)s; return EINVAL; }
int duss_hal_mem_map(void *h, void **p) { (void)h; (void)p; return EINVAL; }
int duss_hal_mem_unmap(void *h) { (void)h; return 0; }
int duss_hal_mem_sync_ext(void *h, unsigned a, unsigned b, uint64_t c) { (void)h; (void)a; (void)b; (void)c; return 0; }

static uint8_t *data;
static size_t data_len;
static int wfd;

static void *writer(void *unused)
{
    (void)unused;
    uint32_t r = 12345;
    for (size_t at = 0; at < data_len;) {
        r = r * 1103515245u + 12345u;
        size_t n = 1 + (r >> 8) % 70000;
        if (n > data_len - at) n = data_len - at;
        ssize_t w = write(wfd, data + at, n);
        if (w > 0) at += (size_t)w;
        else usleep(1000);
        pthread_mutex_lock(&V.mu);
        int d = V.done;
        pthread_mutex_unlock(&V.mu);
        if (d) break;
    }
    return NULL;
}

int main(int argc, char **argv)
{
    if (argc != 5) return 2;
    FILE *f = fopen(argv[1], "rb");
    assert(f);
    fseek(f, 0, SEEK_END);
    data_len = (size_t)ftell(f);
    rewind(f);
    data = malloc(data_len);
    assert(fread(data, 1, data_len, f) == data_len);
    fclose(f);
    uint32_t frames = (uint32_t)atoi(argv[3]), gap = (uint32_t)atoi(argv[4]);
    assert(frames < VR_TS);
    int d = open(argv[2], O_RDONLY | O_DIRECTORY);
    assert(d >= 0);
    unlinkat(d, VR_FILE, 0);
    assert(!prr_mov_openat_mp4(&V.mov, d, VR_FILE, VR_W, VR_H, "avc1", 24000, 1000));
    V.mov.compressor = "H.264";
    /* Timestamps with jitter, and one frame missing before index <gap>. */
    for (uint32_t i = 0; i < frames; i++)
        V.ts[i] = 5000000 + (uint64_t)((i + (i >= gap)) * 41666.667) + (i * 7919 % 3000);
    V.fed = frames;
    V.target = frames;
    V.target_set = 1;
    int p[2];
    assert(!pipe(p));
    fcntl(p[0], F_SETFL, O_NONBLOCK);
    V.out_fd = p[0];
    wfd = p[1];
    V.pid = 1;          /* "alive": kill(1, 0) fails with EPERM, never ESRCH */
    V.child_done = 0;
    pthread_t w;
    pthread_create(&w, NULL, writer, NULL);
    reader(NULL);
    pthread_join(w, NULL);
    printf("err=%d muxed=%u keys=%u sps=%u pps=%u bytes=%llu\n", atomic_load(&V.err), V.muxed, V.keys, V.sps_len,
           V.pps_len, (unsigned long long)atomic_load(&V.bytes));
    assert(!atomic_load(&V.err) && V.muxed == frames && V.sps_len && V.pps_len);
    V.mov.entry_box = V.avcc;
    V.mov.entry_box_len = build_avcc();
    assert(!prr_mov_close(&V.mov));
    return 0;
}
