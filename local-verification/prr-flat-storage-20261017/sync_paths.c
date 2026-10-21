/* Flush only the publication files/directories, not all camera filesystems. */
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
int main(int argc, char **argv) {
    if (argc < 2) return 2;
    for (int i=1; i<argc; ++i) {
        int fd=open(argv[i],O_RDONLY);
        if (fd<0) { perror(argv[i]); return 1; }
        int e=fsync(fd); close(fd);
        if (e) { perror(argv[i]); return 1; }
    }
    return 0;
}
