#include "prr_hal.h"
#include <pthread.h>

int duss_log_initialize(int level, int flags);

static struct prr_hal_device devices[] = {
    { "/dev/msenc0", (void *)duss_hal_attach_msenc, (void *)duss_hal_detach_msenc, 0 },
    { "/dev/msenc1", (void *)duss_hal_attach_msenc, (void *)duss_hal_detach_msenc, 0 },
    { "/dev/msdec0", (void *)duss_hal_attach_codec_msdec, (void *)duss_hal_detach_codec_msdec, 0 },
    { "/dev/msdec1", (void *)duss_hal_attach_codec_msdec, (void *)duss_hal_detach_codec_msdec, 0 },
    { "/dev/ion", (void *)duss_hal_attach_ion_mem, (void *)duss_hal_detach_ion_mem, 0 },
    { "/dev/ion_codec:ms_enc", (void *)duss_hal_attach_ion_mem, (void *)duss_hal_detach_ion_mem, 0 },
    { 0, 0, 0, 0 },
};

static pthread_once_t once = PTHREAD_ONCE_INIT;
static int init_rc;

static void init(void)
{
    duss_log_initialize(3, 0);
    init_rc = duss_hal_initialize(devices);
}

int prr_hal_init(void)
{
    pthread_once(&once, init);
    return init_rc;
}
