#define _GNU_SOURCE 1
#include "preview_exposure.h"
#include "preview_exposure_pin.h"
#include <dlfcn.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>

/* Called only by the resident telemetry worker. Retain the NOLOAD reference:
 * cached function pointers must not outlive the provider mapping. */
int x2v_preview_exposure_read(float *gain)
{
    typedef int (*get_output_fn)(int, void *);
    static get_output_fn get_output;
    static void *provider;
    static unsigned char output[65536];
    if (!get_output) {
        if (!provider) provider = dlopen("/system/lib64/libaaa.so", RTLD_NOW | RTLD_NOLOAD);
        if (!provider) return EAGAIN;
        void *entry = dlsym(provider, "dcam_ae_get_output");
        Dl_info info = {0};
        if (!entry || !dladdr(entry, &info) || !info.dli_fname ||
            !strstr(info.dli_fname, "/libaaa.so") || memcmp(entry, x2v_ae_output_entry, sizeof x2v_ae_output_entry)) return EPROTO;
        memcpy(&get_output, &entry, sizeof get_output);
        fprintf(stderr, "X2V_EXPOSURE native AE output bound\n");
    }
    memset(output, 0, sizeof output);
    int rc = get_output(0, output);
    return rc ? rc : x2v_preview_exposure_gain(output, sizeof output, gain);
}
