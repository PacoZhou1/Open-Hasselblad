/* On-camera: who runs while the SSD's completions stop. Every <ms> for <n> intervals: NVMe
 * completion interrupts, per-CPU busy time and every thread's CPU time (schedstat, ns); prints,
 * per interval, the completions, the per-CPU busy % and the threads that ran >= <min_ms> of it,
 * as comm/tid:ms<policy><rtprio> (F fifo, R rr, o other).
 * Usage: bench_tstat <ms> <n> [min_ms=4] [threads|procs|none]  (procs: per process, far cheaper) */
#include <dirent.h>
#include <fcntl.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

#define MAXT 4096
struct info { int tid, prio, policy; char comm[20]; };
struct th { int tid; uint64_t run_ns; };
struct snap { uint64_t ns, nvme, cpu[4][2]; int n; struct th *t; };

static struct info infos[MAXT];
static int ninfo;
static enum { THREADS, PROCS, NONE } mode;

static uint64_t now_ns(void)
{
    struct timespec t;
    clock_gettime(CLOCK_MONOTONIC, &t);
    return (uint64_t)t.tv_sec * 1000000000ull + (uint64_t)t.tv_nsec;
}

/* procfs hands out about a page per read. */
static ssize_t slurp(const char *path, char *buf, size_t cap)
{
    int fd = open(path, O_RDONLY | O_CLOEXEC);
    if (fd < 0) return -1;
    size_t n = 0;
    for (ssize_t r; n < cap - 1 && (r = read(fd, buf + n, cap - 1 - n)) > 0;) n += (size_t)r;
    close(fd);
    buf[n] = 0;
    return (ssize_t)n;
}

static uint64_t nvme_irqs(void)
{
    static char b[65536];
    if (slurp("/proc/interrupts", b, sizeof b) <= 0) return 0;
    uint64_t sum = 0;
    char *l = b;
    while (l && *l) {
        char *e = strchr(l, '\n');
        if (e) *e = 0;
        if (strstr(l, "nvme0q") && !strstr(l, "nvme0q0")) {
            char *p = strchr(l, ':');
            for (int c = 0; p && c < 4; c++) sum += strtoull(p + 1, &p, 10);
        }
        l = e ? e + 1 : NULL;
    }
    return sum;
}

static void cpus(uint64_t c[4][2])
{
    static char b[8192];
    if (slurp("/proc/stat", b, sizeof b) <= 0) return;
    for (int i = 0; i < 4; i++) {
        char key[8];
        snprintf(key, sizeof key, "\ncpu%d ", i);
        char *p = strstr(b, key);
        if (!p) continue;
        p += strlen(key);
        uint64_t v[8] = { 0 };
        for (int k = 0; k < 8; k++) v[k] = strtoull(p, &p, 10);
        c[i][0] = v[0] + v[1] + v[2] + v[5] + v[6] + v[7];    /* user nice system irq softirq steal */
        c[i][1] = c[i][0] + v[3] + v[4];
    }
}

static void learn(const char *pid, const char *tid)
{
    if (ninfo >= MAXT) return;
    char path[96], b[1024];
    if (tid) snprintf(path, sizeof path, "/proc/%s/task/%s/stat", pid, tid);
    else snprintf(path, sizeof path, "/proc/%s/stat", pid);
    if (slurp(path, b, sizeof b) <= 0) return;
    char *l = strchr(b, '('), *r = strrchr(b, ')');
    if (!l || !r) return;
    struct info *t = &infos[ninfo++];
    t->tid = atoi(tid ? tid : pid);
    size_t cl = (size_t)(r - l - 1) < sizeof t->comm - 1 ? (size_t)(r - l - 1) : sizeof t->comm - 1;
    memcpy(t->comm, l + 1, cl);
    t->comm[cl] = 0;
    /* after ") ": field 3 is the state letter, then numbers up to 40 rt_priority, 41 policy */
    char *p = r + 2;
    while (*p && *p != ' ') p++;
    unsigned long long f[42] = { 0 };
    for (int k = 4; k <= 41 && *p; k++) f[k] = strtoull(p, &p, 10);
    t->prio = (int)f[40];
    t->policy = (int)f[41];
}

static const struct info *info_of(int tid)
{
    for (int i = 0; i < ninfo; i++) if (infos[i].tid == tid) return &infos[i];
    return NULL;
}

static void take(struct snap *s)
{
    s->ns = now_ns();
    s->nvme = nvme_irqs();
    cpus(s->cpu);
    s->n = 0;
    if (mode == NONE) return;
    DIR *pd = opendir("/proc");
    if (!pd) return;
    struct dirent *pe;
    char path[96], b[256];
    while ((pe = readdir(pd)) && s->n < MAXT) {
        if (pe->d_name[0] < '1' || pe->d_name[0] > '9') continue;
        int split = 0;
        if (mode == PROCS) {
            /* A process's schedstat is its main thread's: the multi-threaded ones that matter go by thread. */
            char comm[32];
            snprintf(path, sizeof path, "/proc/%s/comm", pe->d_name);
            split = slurp(path, comm, sizeof comm) > 0 &&
                    (!strncmp(comm, "camera-service", 14) || !strncmp(comm, "test_venc_e2", 12));
        }
        if (mode == PROCS && !split) {
            snprintf(path, sizeof path, "/proc/%s/schedstat", pe->d_name);
            if (slurp(path, b, sizeof b) <= 0) continue;
            int pid = atoi(pe->d_name);
            if (!info_of(pid)) learn(pe->d_name, NULL);
            s->t[s->n].tid = pid;
            s->t[s->n].run_ns = strtoull(b, NULL, 10);
            s->n++;
            continue;
        }
        snprintf(path, sizeof path, "/proc/%s/task", pe->d_name);
        DIR *td = opendir(path);
        if (!td) continue;
        struct dirent *te;
        while ((te = readdir(td)) && s->n < MAXT) {
            if (te->d_name[0] < '1' || te->d_name[0] > '9') continue;
            snprintf(path, sizeof path, "/proc/%s/task/%s/schedstat", pe->d_name, te->d_name);
            if (slurp(path, b, sizeof b) <= 0) continue;
            int tid = atoi(te->d_name);
            if (!info_of(tid)) learn(pe->d_name, te->d_name);
            s->t[s->n].tid = tid;
            s->t[s->n].run_ns = strtoull(b, NULL, 10);
            s->n++;
        }
        closedir(td);
    }
    closedir(pd);
}

static const struct th *find(const struct snap *s, int tid)
{
    for (int i = 0; i < s->n; i++) if (s->t[i].tid == tid) return &s->t[i];
    return NULL;
}

int main(int argc, char **argv)
{
    if (argc < 3) return 2;
    int ms = atoi(argv[1]), n = atoi(argv[2]), min_ms = argc > 3 ? atoi(argv[3]) : 4;
    if (argc > 4) mode = !strcmp(argv[4], "procs") ? PROCS : !strcmp(argv[4], "none") ? NONE : THREADS;
    struct snap *s = calloc((size_t)n + 1, sizeof *s);
    for (int i = 0; i <= n; i++) s[i].t = calloc(MAXT, sizeof(struct th));
    uint64_t t0 = now_ns();
    for (int i = 0; i <= n; i++) {
        uint64_t due = t0 + (uint64_t)i * (uint64_t)ms * 1000000ull;
        for (uint64_t t = now_ns(); t < due; t = now_ns()) usleep((useconds_t)((due - t) / 1000));
        take(&s[i]);
    }
    for (int i = 1; i <= n; i++) {
        const struct snap *a = &s[i - 1], *b = &s[i];
        printf("%6.0f nvme=%-4llu cpu", (double)(b->ns - t0) / 1e6, (unsigned long long)(b->nvme - a->nvme));
        for (int c = 0; c < 4; c++) {
            uint64_t busy = b->cpu[c][0] - a->cpu[c][0], tot = b->cpu[c][1] - a->cpu[c][1];
            printf(" %3llu", tot ? (unsigned long long)(busy * 100 / tot) : 0ull);
        }
        printf(" |");
        for (int k = 0; k < b->n; k++) {
            const struct th *o = find(a, b->t[k].tid);
            if (!o) continue;
            uint64_t d = (b->t[k].run_ns - o->run_ns) / 1000000ull;
            const struct info *f = info_of(b->t[k].tid);
            if (d >= (uint64_t)min_ms && f)
                printf(" %s/%d:%llu%s%d", f->comm, f->tid, (unsigned long long)d,
                       f->policy == 1 ? "F" : f->policy == 2 ? "R" : "o", f->prio);
        }
        printf("\n");
    }
    return 0;
}
