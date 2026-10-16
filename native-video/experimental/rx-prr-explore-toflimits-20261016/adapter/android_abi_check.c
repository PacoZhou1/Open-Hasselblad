#include <sys/stat.h>
#include <sys/types.h>
#include <stddef.h>
#include <time.h>
#include <fcntl.h>
_Static_assert(sizeof(struct stat)==128,"AArch64 Bionic stat128");
_Static_assert(offsetof(struct stat,st_dev)==0,"st_dev");
_Static_assert(offsetof(struct stat,st_ino)==8,"st_ino");
_Static_assert(offsetof(struct stat,st_mode)==16,"st_mode");
_Static_assert(offsetof(struct stat,st_nlink)==20,"st_nlink");
_Static_assert(offsetof(struct stat,st_size)==48,"st_size");
_Static_assert(sizeof(off_t)==8,"off_t64");
_Static_assert(sizeof(struct timespec)==16,"timespec16");
_Static_assert(O_DIRECT==0x10000,"Android ARM64 O_DIRECT");
_Static_assert(AT_SYMLINK_NOFOLLOW==0x100,"fstatat flags");
