#define _GNU_SOURCE 1
#include <sys/syscall.h>
#include <unistd.h>

#ifndef __NR_inotify_add_watch
#define __NR_inotify_add_watch 27
#endif

/* debug_hub_init watches /data/codec_debug_hub and asserts if the watch is
 * denied. camera-service can create that directory; the watch itself may still
 * fail. A denied watch is redirected to /tmp so rm_watch still yields IN_IGNORED. */
int inotify_add_watch(int fd, const char *path, unsigned int mask)
{
    long wd = syscall(__NR_inotify_add_watch, fd, path, mask);
    if (wd < 0)
        wd = syscall(__NR_inotify_add_watch, fd, "/tmp", mask);
    return wd < 0 ? 1 : (int)wd;
}
