#define _GNU_SOURCE 1
#include <dlfcn.h>
#include <errno.h>
#include <fcntl.h>
#include <stdarg.h>
#include <stdatomic.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/syscall.h>
#include <unistd.h>

const char *x2v_reference_iq_path(const char *path)
{
    if (!path) return path;
    const char *name = strrchr(path, '/');
    name = name ? name + 1 : path;
    if (strcmp(name, "hb722_config.bin")) return path;
    const char *target = getenv("X2V_REFERENCE_IQ");
    if (!target || strncmp(target, "/blackbox/x2v-native-20261011/", sizeof "/blackbox/x2v-native-20261011/" - 1)) return path;
    static _Atomic int logged;
    if (!atomic_exchange(&logged, 1))
        fprintf(stderr, "X2V_REFERENCE_IQ from=%s to=%s\n", path, target);
    return target;
}

static mode_t mode_arg(int flags, va_list ap)
{
    return (flags & O_CREAT) || (flags & O_TMPFILE) == O_TMPFILE ? (mode_t)va_arg(ap, int) : 0;
}
#define OPEN_FN(name) \
int name(const char *path, int flags, ...) { \
    va_list ap; va_start(ap, flags); mode_t mode = mode_arg(flags, ap); va_end(ap); \
    return (int)syscall(SYS_openat, AT_FDCWD, x2v_reference_iq_path(path), flags, mode); \
}
#define OPENAT_FN(name) \
int name(int dir, const char *path, int flags, ...) { \
    va_list ap; va_start(ap, flags); mode_t mode = mode_arg(flags, ap); va_end(ap); \
    return (int)syscall(SYS_openat, dir, x2v_reference_iq_path(path), flags, mode); \
}
OPEN_FN(open)
OPEN_FN(open64)
OPENAT_FN(openat)
OPENAT_FN(openat64)

/* fopen already belongs to the reviewed graph parser binding. That derived
 * binding calls x2v_reference_iq_path without replacing its existing FD guards. */
FILE *fopen64(const char *path, const char *mode) { return fopen(x2v_reference_iq_path(path), mode); }
