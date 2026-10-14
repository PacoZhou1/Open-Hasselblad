/* Can this SELinux domain rewrite a private copy of camera-service text? Maps the page holding
   setFullPressActive (VA 0x15a7e8) the way the loader does, then tries the two ways in:
   RW then back to RX (execmod), and RWX (execmem). Prints the instruction words and errnos. */
#include <errno.h>
#include <fcntl.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>

#define ENTRY 0x15a7e8u

static void attempt(const char *how, int fd, int rwx)
{
    uint8_t *m = mmap(NULL, 4096, PROT_READ | PROT_EXEC, MAP_PRIVATE, fd, ENTRY & ~4095u);
    if (m == MAP_FAILED) { printf("%s mmap errno=%d\n", how, errno); return; }
    volatile uint32_t *w = (uint32_t *)(m + (ENTRY & 4095u));
    printf("%s words %08x %08x %08x %08x\n", how, w[0], w[1], w[2], w[3]);
    int e1 = mprotect(m, 4096, rwx ? PROT_READ | PROT_WRITE | PROT_EXEC : PROT_READ | PROT_WRITE) ? errno : 0;
    int e2 = -1;
    if (!e1) {
        w[0] = w[0];
        e2 = rwx ? 0 : mprotect(m, 4096, PROT_READ | PROT_EXEC) ? errno : 0;
    }
    printf("%s protect_errno=%d restore_errno=%d\n", how, e1, e2);
    munmap(m, 4096);
}

int main(void)
{
    char ctx[128] = {0};
    int c = open("/proc/self/attr/current", O_RDONLY);
    if (c >= 0) { ssize_t n = read(c, ctx, sizeof ctx - 1); (void)n; close(c); }
    printf("context %s\n", ctx);
    int fd = open("/system/bin/camera-service", O_RDONLY);
    if (fd < 0) { printf("open errno=%d\n", errno); return 1; }
    attempt("rw_rx", fd, 0);
    attempt("rwx", fd, 1);
    close(fd);
    return 0;
}
