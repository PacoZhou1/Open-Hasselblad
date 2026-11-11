/* REVIEW ONLY, unbuilt/unloaded. Compile into isolated library only after ELF
 * version/export review. This reads the result of an existing native getter;
 * it does not issue a new camera operation, alter FPS, or modify any argument. */
#define _GNU_SOURCE 1
#include <dlfcn.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#ifndef X2V_DEBUG_VOT_TRANSPORT
#define X2V_DEBUG_VOT_TRANSPORT 0
#endif
extern void *__loader_dlsym(void *, const char *, const void *);
static int aio_caller(void *pc, uintptr_t expected)
{
    Dl_info d = {0};
    if (!dladdr(pc, &d) || !d.dli_fname || !d.dli_fbase) return 0;
    const char *name = strrchr(d.dli_fname, '/');
    name = name ? name + 1 : d.dli_fname;
    if (strcmp(name, "libdcam_plugins_AIO.so")) return 0;
    /* Derive bias from an actual exported native symbol, not dli_fbase:
     * matching AIO first PT_LOAD VA is 0x7000, so those are not equivalent. */
    void *anchor = __loader_dlsym(RTLD_DEFAULT,
        "_dsh_frame_buffer_remote_observer_on_frame", (const void *)&aio_caller);
    Dl_info a = {0};
    if (!anchor || !dladdr(anchor, &a) || a.dli_fbase != d.dli_fbase ||
        a.dli_saddr != anchor) return 0;
    return (uintptr_t)pc == (uintptr_t)anchor - 0x1dc040 + expected;
}
int cam_stream_consumer_get_parameter(void *consumer, const char *name,
                                     void *out, unsigned bytes)
{
    typedef int (*Fn)(void *, const char *, void *, unsigned);
    void *p = __loader_dlsym(RTLD_NEXT, "cam_stream_consumer_get_parameter",
                           (const void *)&cam_stream_consumer_get_parameter);
    Fn native;
    memcpy(&native, &p, sizeof native);
    if (!native) return -1003;
    int rc = native(consumer, name, out, bytes);
    if (X2V_DEBUG_VOT_TRANSPORT && !rc && out && bytes >= 4 && name &&
        !strcmp(name, "fps") && aio_caller(__builtin_return_address(0), 0x1d20ac)) {
        uint32_t fps;
        memcpy(&fps, out, 4);
        fprintf(stderr, "X2V_VOT_TRANSPORT observer_input_fps_raw=%u consumer=%p\n",
                fps, consumer);
    }
    return rc;
}
int cam_frame_buffer_remote_observer_start(void *observer, const void *cfg)
{
    typedef int (*Fn)(void *, const void *);
    void *p = __loader_dlsym(RTLD_NEXT, "cam_frame_buffer_remote_observer_start",
                           (const void *)&cam_frame_buffer_remote_observer_start);
    Fn native;
    memcpy(&native, &p, sizeof native);
    if (!native) return -1003;
    if (X2V_DEBUG_VOT_TRANSPORT && cfg &&
        aio_caller(__builtin_return_address(0), 0x1d2164)) {
        uint32_t fps, count;
        memcpy(&fps, cfg, 4);
        memcpy(&count, (const char *)cfg + 0x18, 4);
        fprintf(stderr, "X2V_VOT_TRANSPORT observer_start_fps=%u buffers=%u observer=%p\n",
                fps, count, observer);
    }
    return native(observer, cfg);
}
