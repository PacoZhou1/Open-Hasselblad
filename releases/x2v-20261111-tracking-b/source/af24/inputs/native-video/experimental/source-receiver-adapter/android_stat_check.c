#include <pthread.h>
#include <sys/stat.h>
#include <stddef.h>
/* Confirm Zig's Linux/AArch64 header agrees with native direct fstat syscall. */
_Static_assert(sizeof(struct stat)==128,"Linux ARM64 stat size");
_Static_assert(offsetof(struct stat,st_mode)==16,"stat mode");
_Static_assert(offsetof(struct stat,st_nlink)==20,"stat nlink");
_Static_assert(offsetof(struct stat,st_size)==48,"stat size");
_Static_assert(sizeof(pthread_t)==8,"opaque pthread_t ARM64");
