#ifdef X2V_ANDROID
#include <errno.h>
#undef errno
extern int *__errno(void);
#define errno (*__errno())
/* AArch64 Bionic fstat is the direct Linux syscall80. Target system stat
 * header must match that ABI; enforced in android_stat_check.c. */
#endif
