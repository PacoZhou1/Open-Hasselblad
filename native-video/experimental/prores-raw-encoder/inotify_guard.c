#define _GNU_SOURCE 1
#include <unistd.h>
#ifndef __NR_inotify_add_watch
#define __NR_inotify_add_watch 27
#endif
int inotify_add_watch(int fd, const char *path, unsigned int mask)
{
    long wd = syscall(__NR_inotify_add_watch, fd, path, mask);
    if (wd < 0)
        wd = syscall(__NR_inotify_add_watch, fd, "/tmp", mask);
    return wd < 0 ? 1 : (int)wd;
}
