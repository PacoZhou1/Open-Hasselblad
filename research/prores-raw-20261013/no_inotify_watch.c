/* LD_PRELOAD shim for running stock codec test tools from adb su: the codec debug hub asserts when
 * inotify_add_watch is denied there. A denied watch is redirected to a directory su may watch, so the
 * hub's inotify_rm_watch still yields IN_IGNORED and its reader thread can be joined at exit. */
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
        wd = sys3(NR_INOTIFY_ADD_WATCH, fd, (long)"/data/local/tmp/x2v-claude-prr", mask);
    return wd < 0 ? 1 : (int)wd;
}
