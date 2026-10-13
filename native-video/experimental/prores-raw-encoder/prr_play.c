/* x2v_prr_play: ProRes RAW .mov → Moonshadow msdec → RGB888 on a local HTTP
 * surface. The product gallery loads /frame.ppm; nothing here writes HEVC. */
#include "prr_dec.h"
#include "prr_movr.h"
#include "prr_view.h"
#include <arpa/inet.h>
#include <errno.h>
#include <fcntl.h>
#include <netinet/in.h>
#include <pthread.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/select.h>
#include <sys/socket.h>
#include <sys/stat.h>
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

#define DEFAULT_DIR "/blackbox/x2v-native-20261011/play"
#define DEFAULT_LISTEN "127.0.0.1:18763"
#define MAX_SRC 512
#define HDR 64

enum play_phase { PH_IDLE, PH_LOADING, PH_PLAYING, PH_PAUSED, PH_ENDED, PH_ERROR };

struct player {
    char dir[256];
    char source[MAX_SRC];
    char error[160];
    enum play_phase phase;
    int scale, threads, listen_fd, generation, index, count;
    int out_w, out_h;
    double fps, position, duration;
    uint8_t *rgb;
    uint8_t *ppm;
    size_t ppm_len;
    struct prr_movr mv;
    struct prr_dec dec;
    struct prr_view view;
    int dec_open, mv_open;
    double next_ms;
};

static double now_ms(void)
{
    struct timespec t;
    clock_gettime(CLOCK_MONOTONIC, &t);
    return t.tv_sec * 1e3 + t.tv_nsec / 1e6;
}

static const char *phase_name(enum play_phase p)
{
    switch (p) {
    case PH_LOADING: return "loading";
    case PH_PLAYING: return "playing";
    case PH_PAUSED: return "paused";
    case PH_ENDED: return "ended";
    case PH_ERROR: return "error";
    default: return "idle";
    }
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

struct render_job {
    const struct prr_view *v;
    const uint16_t *bayer;
    int stride;
    uint8_t *rgb;
    int r0, r1;
};

static void *render_job_fn(void *arg)
{
    struct render_job *j = arg;
    prr_view_rows(j->v, j->bayer, j->stride, j->rgb, j->r0, j->r1);
    return NULL;
}

static void render(const struct prr_view *v, const uint16_t *bayer, int stride, uint8_t *rgb, int threads)
{
    struct render_job j[8];
    pthread_t t[8];
    int n = threads < 1 ? 1 : threads > 8 ? 8 : threads;
    for (int i = 0; i < n; i++) {
        j[i] = (struct render_job){ v, bayer, stride, rgb, v->out_h * i / n, v->out_h * (i + 1) / n };
        if (i && pthread_create(&t[i], NULL, render_job_fn, &j[i]))
            render_job_fn(&j[i]), t[i] = 0;
    }
    render_job_fn(&j[0]);
    for (int i = 1; i < n; i++)
        if (t[i])
            pthread_join(t[i], NULL);
}

static void close_clip(struct player *p)
{
    if (p->mv_open) {
        prr_movr_close(&p->mv);
        p->mv_open = 0;
    }
    if (p->dec_open) {
        prr_dec_close(&p->dec);
        p->dec_open = 0;
    }
    p->count = p->index = 0;
    p->position = p->duration = 0;
    p->source[0] = 0;
}

static int pack_ppm(struct player *p)
{
    char hdr[HDR];
    int hl = snprintf(hdr, sizeof hdr, "P6\n%d %d\n255\n", p->out_w, p->out_h);
    size_t rgb_n = (size_t)p->out_w * (size_t)p->out_h * 3;
    size_t n = (size_t)hl + rgb_n;
    uint8_t *buf = realloc(p->ppm, n);
    if (!buf || !p->rgb)
        return -1;
    p->ppm = buf;
    memcpy(p->ppm, hdr, (size_t)hl);
    memcpy(p->ppm + hl, p->rgb, rgb_n);
    p->ppm_len = n;
    p->generation++;
    return 0;
}

static void dump_files(const struct player *p)
{
    char path[600], tmp[600];
    if (!p->dir[0] || !p->ppm || !p->ppm_len)
        return;
    snprintf(tmp, sizeof tmp, "%s/frame.ppm.tmp", p->dir);
    snprintf(path, sizeof path, "%s/frame.ppm", p->dir);
    int fd = open(tmp, O_WRONLY | O_CREAT | O_TRUNC | O_CLOEXEC, 0644);
    if (fd < 0 || write_all(fd, p->ppm, p->ppm_len)) {
        if (fd >= 0)
            close(fd);
        return;
    }
    close(fd);
    rename(tmp, path);
}

static int decode_index(struct player *p, int idx)
{
    int len = prr_movr_read(&p->mv, (uint32_t)idx, prr_dec_input(&p->dec), p->dec.stream_cap);
    struct prr_dec_meta meta = { 0 };
    if (len < 0 || prr_dec_decode(&p->dec, (uint32_t)len, &meta))
        return -1;
    prr_view_setup(&p->view, &meta, p->dec.width, p->dec.height, p->scale, 0);
    if (!p->rgb || p->out_w != p->view.out_w || p->out_h != p->view.out_h) {
        free(p->rgb);
        p->rgb = malloc((size_t)p->view.out_w * (size_t)p->view.out_h * 3);
        p->out_w = p->view.out_w;
        p->out_h = p->view.out_h;
    }
    if (!p->rgb)
        return -1;
    render(&p->view, p->dec.fva, p->dec.stride, p->rgb, p->threads);
    if (pack_ppm(p))
        return -1;
    dump_files(p);
    p->index = idx;
    p->position = p->fps > 0 ? idx / p->fps : 0;
    return 0;
}

static void fail(struct player *p, const char *msg)
{
    snprintf(p->error, sizeof p->error, "%s", msg);
    p->phase = PH_ERROR;
    close_clip(p);
}

static void open_clip(struct player *p, const char *src)
{
    close_clip(p);
    p->error[0] = 0;
    p->phase = PH_LOADING;
    snprintf(p->source, sizeof p->source, "%s", src);
    if (prr_movr_open(&p->mv, src)) {
        fail(p, "无法打开 ProRes RAW");
        return;
    }
    p->mv_open = 1;
    p->count = (int)p->mv.count;
    p->fps = p->mv.timescale && p->mv.sample_duration ?
        (double)p->mv.timescale / (double)p->mv.sample_duration : 24.0;
    p->duration = p->count && p->fps > 0 ? p->count / p->fps : 0;
    if (prr_dec_open(&p->dec, prr_movr_max_size(&p->mv), 2)) {
        fail(p, "msdec 未就绪");
        return;
    }
    p->dec_open = 1;
    if (!p->count || decode_index(p, 0)) {
        fail(p, "首帧解码失败");
        return;
    }
    p->phase = PH_PLAYING;
    p->next_ms = now_ms() + (p->fps > 0 ? 1000.0 / p->fps : 41.67);
}

static void tick_play(struct player *p)
{
    if (p->phase != PH_PLAYING || !p->dec_open)
        return;
    double t = now_ms();
    if (t < p->next_ms)
        return;
    int next = p->index + 1;
    if (next >= p->count) {
        p->phase = PH_ENDED;
        return;
    }
    if (decode_index(p, next)) {
        fail(p, "解码失败");
        return;
    }
    p->next_ms += p->fps > 0 ? 1000.0 / p->fps : 41.67;
    if (p->next_ms < t - 250)
        p->next_ms = t;
}

static void skip_ws(const char **s)
{
    while (**s == ' ' || **s == '\t' || **s == '\r' || **s == '\n')
        (*s)++;
}

static void apply_cmd(struct player *p, const char *body)
{
    const char *s = body;
    char op[16], src[MAX_SRC];
    int n = 0;
    skip_ws(&s);
    while (s[n] && s[n] != ' ' && s[n] != '\n' && s[n] != '\r' && n < 15) {
        op[n] = s[n];
        n++;
    }
    op[n] = 0;
    s += n;
    skip_ws(&s);
    n = 0;
    while (s[n] && s[n] != ' ' && s[n] != '\n' && s[n] != '\r' && n < MAX_SRC - 1) {
        src[n] = s[n];
        n++;
    }
    src[n] = 0;
    if (!strcmp(op, "open") && src[0])
        open_clip(p, src);
    else if (!strcmp(op, "stop")) {
        close_clip(p);
        p->phase = PH_IDLE;
        p->error[0] = 0;
    } else if (!strcmp(op, "pause") && p->phase == PH_PLAYING)
        p->phase = PH_PAUSED;
    else if (!strcmp(op, "resume") && p->phase == PH_PAUSED) {
        p->phase = PH_PLAYING;
        p->next_ms = now_ms() + (p->fps > 0 ? 1000.0 / p->fps : 41.67);
    }
}

static int write_http(int fd, int code, const char *ctype, const void *body, size_t n)
{
    char hdr[256];
    int hl = snprintf(hdr, sizeof hdr,
                      "HTTP/1.1 %d %s\r\nContent-Type: %s\r\nContent-Length: %zu\r\n"
                      "Connection: close\r\nCache-Control: no-store\r\n\r\n",
                      code, code == 200 ? "OK" : "ERR", ctype, n);
    if (write_all(fd, hdr, (size_t)hl))
        return -1;
    return body && n ? write_all(fd, body, n) : 0;
}

static void handle_client(struct player *p, int fd)
{
    char req[2048];
    size_t n = 0;
    while (n + 1 < sizeof req) {
        ssize_t r = recv(fd, req + n, sizeof req - 1 - n, 0);
        if (r <= 0)
            break;
        n += (size_t)r;
        req[n] = 0;
        if (strstr(req, "\r\n\r\n"))
            break;
    }
    char *blank = strstr(req, "\r\n\r\n");
    char *body = blank ? blank + 4 : req + n;
    if (!strncmp(req, "POST /cmd", 9)) {
        apply_cmd(p, body);
        write_http(fd, 200, "text/plain", "ok\n", 3);
        return;
    }
    if (!strncmp(req, "GET /state", 10)) {
        char js[768];
        int m = snprintf(js, sizeof js,
                         "{\"schema\":1,\"phase\":\"%s\",\"source\":\"%s\",\"index\":%d,\"count\":%d,"
                         "\"width\":%d,\"height\":%d,\"position\":%.4f,\"duration\":%.4f,"
                         "\"generation\":%d,\"error\":\"%s\"}\n",
                         phase_name(p->phase), p->source, p->index, p->count, p->out_w, p->out_h,
                         p->position, p->duration, p->generation, p->error);
        write_http(fd, 200, "application/json", js, (size_t)m);
        return;
    }
    if (!strncmp(req, "GET /frame.ppm", 14) && p->ppm && p->ppm_len) {
        write_http(fd, 200, "image/x-portable-pixmap", p->ppm, p->ppm_len);
        return;
    }
    write_http(fd, 404, "text/plain", "no\n", 3);
}

static int listen_on(const char *spec)
{
    char host[64] = "127.0.0.1";
    int port = 18763;
    const char *colon = strrchr(spec, ':');
    if (colon) {
        size_t hl = (size_t)(colon - spec);
        if (hl >= sizeof host)
            hl = sizeof host - 1;
        memcpy(host, spec, hl);
        host[hl] = 0;
        port = atoi(colon + 1);
    }
    int fd = socket(AF_INET, SOCK_STREAM, 0);
    int on = 1;
    if (fd < 0)
        return -1;
    setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &on, sizeof on);
    struct sockaddr_in a;
    memset(&a, 0, sizeof a);
    a.sin_family = AF_INET;
    a.sin_port = htons((uint16_t)port);
    if (inet_pton(AF_INET, host, &a.sin_addr) != 1) {
        close(fd);
        return -1;
    }
    if (bind(fd, (struct sockaddr *)&a, sizeof a) || listen(fd, 8)) {
        close(fd);
        return -1;
    }
    return fd;
}

static int usage(void)
{
    fprintf(stderr, "usage: x2v_prr_play [--listen 127.0.0.1:18763] [--dir DIR] [--scale 4] [--threads 2] [-i clip.mov]\n");
    return 2;
}

int main(int argc, char **argv)
{
    struct player p;
    memset(&p, 0, sizeof p);
    p.scale = 4;
    p.threads = 2;
    snprintf(p.dir, sizeof p.dir, "%s", DEFAULT_DIR);
    const char *listen = DEFAULT_LISTEN;
    const char *initial = NULL;
    for (int i = 1; i < argc; i++) {
        const char *a = argv[i], *v = i + 1 < argc ? argv[i + 1] : NULL;
        if (!strcmp(a, "--listen") && v)
            listen = v, i++;
        else if (!strcmp(a, "--dir") && v)
            snprintf(p.dir, sizeof p.dir, "%s", v), i++;
        else if (!strcmp(a, "--scale") && v)
            p.scale = (int)strtol(v, NULL, 10), i++;
        else if (!strcmp(a, "--threads") && v)
            p.threads = (int)strtol(v, NULL, 10), i++;
        else if (!strcmp(a, "-i") && v)
            initial = v, i++;
        else
            return usage();
    }
    signal(SIGPIPE, SIG_IGN);
    mkdir(p.dir, 0755);
    p.listen_fd = listen_on(listen);
    if (p.listen_fd < 0) {
        fprintf(stderr, "listen %s: %s\n", listen, strerror(errno));
        return 1;
    }
    if (initial)
        open_clip(&p, initial);
    for (;;) {
        tick_play(&p);
        fd_set rfds;
        FD_ZERO(&rfds);
        FD_SET(p.listen_fd, &rfds);
        struct timeval tv = { .tv_sec = 0, .tv_usec = 5000 };
        int rc = select(p.listen_fd + 1, &rfds, NULL, NULL, &tv);
        if (rc > 0 && FD_ISSET(p.listen_fd, &rfds)) {
            int c = accept(p.listen_fd, NULL, NULL);
            if (c >= 0) {
                handle_client(&p, c);
                close(c);
            }
        }
    }
#ifdef X2V_ANDROID
    _exit(0);
#else
    return 0;
#endif
}
