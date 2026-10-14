/* Loads a weston module exactly as weston 12 does (dlopen RTLD_NOW, wet_module_init)
 * so the boot module can be proven on the device before weston.ini names it. */
#include <dlfcn.h>
#include <stdio.h>

int main(int argc, char *argv[])
{
    if (argc != 2) {
        fprintf(stderr, "usage: %s module.so\n", argv[0]);
        return 2;
    }
    void *h = dlopen(argv[1], RTLD_NOW);
    if (!h) {
        printf("dlopen_failed %s\n", dlerror());
        return 1;
    }
    int (*init)(void *, int *, char **) = (int (*)(void *, int *, char **))dlsym(h, "wet_module_init");
    if (!init) {
        printf("no_wet_module_init\n");
        return 1;
    }
    int n = 0;
    int rc = init(NULL, &n, NULL);
    printf("wet_module_init rc=%d\n", rc);
    return rc ? 1 : 0;
}
