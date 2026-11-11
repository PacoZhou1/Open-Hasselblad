#include "preview_exposure.h"
static _Atomic float preview_gain = 1.0f;
static _Atomic uint64_t preview_gain_at;
static _Atomic uint32_t preview_sample_us_max;
static float preview_gain_for_frame(int *valid)
{
    uint64_t at = atomic_load(&preview_gain_at);
    *valid = at && now_ns() - at < 2000000000ull;
    return *valid ? atomic_load(&preview_gain) : 1.0f;
}
static void *preview_exposure_worker(void *unused)
{
    (void)unused;
    pthread_setname_np(pthread_self(), "x2v-exposure");
    int previous = -999;
    while (!atomic_load(&released)) {
        tools_stats_poll();
        /* RCAM loads/initializes AAA after preload construction. Source colour
         * frames establish that its graph is running before querying AAA. */
        if (atomic_load(&S.pv_seen) >= 2) {
            float gain = 1.0f;
            uint64_t t = now_ns();
            int e = x2v_preview_exposure_read(&gain);
            uint32_t us = (uint32_t)((now_ns() - t) / 1000);
            if (us > atomic_load(&preview_sample_us_max)) atomic_store(&preview_sample_us_max, us);
            if (!e) {
                atomic_store(&preview_gain, gain);
                atomic_store(&preview_gain_at, now_ns());
            }
            if (e != previous) fprintf(stderr, "X2V_EXPOSURE state=%d gain=%.5f sample_us=%u\n", e, gain, us);
            previous = e;
        }
        usleep(100000);
    }
    return NULL;
}

static pthread_t reference_exposure_thread;
static int reference_exposure_started;
static void reference_exposure_stop(void)
{
    /* Called after released=1 and before acknowledging teardown. Native AAA
     * cannot be destroyed while the telemetry thread is still inside it. */
    if (reference_exposure_started) {
        pthread_join(reference_exposure_thread, NULL);
        reference_exposure_started = 0;
    }
}
