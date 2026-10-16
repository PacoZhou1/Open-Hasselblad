/* While a resident session holds the camera, the full press is the record button and nothing
 * else: counted in /tmp/x2v-live/shutter, which the GUI polls, and never a still (a still
 * request on the RAW graph hangs the camera until the battery comes out).
 *
 * The physical shutter does not come as a key on the body-button device: it reaches the
 * service's state machine through the capture service (DUSS). Both that and the input control's
 * full press end in X2DCameraStateMachine::setFullPressActive(bool) before anything marks it
 * held, adds a half press or exposes, so that entry is turned into full_press() below (only
 * this library's camera-service has it, and only for the video session). The half press keeps
 * its own path: with the GUI's key override at None the service does AF, puts prompts away and
 * goes back to live view on it as in photo mode.
 *
 * Should the entry not be there, the GUI falls back to Override(3): no still then, and the
 * service forwards the press as KEY_E to its uinput device, caught in
 * libevdev_uinput_write_event below. What reaches the input control and what it writes back
 * out are logged either way. */
#define _GNU_SOURCE 1
#include <dlfcn.h>
#include <errno.h>
#include <fcntl.h>
#include <link.h>
#include <linux/input.h>
#include <stdatomic.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>

struct libevdev;
struct libevdev_uinput;
extern void *__loader_dlsym(void *, const char *, const void *);
extern int x2v_session_guard(void);

#define SHUTTER_FILE "/tmp/x2v-live/shutter"
#define GATE_FILE "/tmp/x2v-live/fullpress"

static _Atomic unsigned presses;
static int held;   /* a swallowed press whose release is still to come */

static void write_small(const char *path, const char *b, int len)
{
    char tmp[64];
    snprintf(tmp, sizeof tmp, "%s.tmp", path);
    int fd = open(tmp, O_WRONLY | O_CREAT | O_TRUNC | O_CLOEXEC, 0644);
    if (fd < 0) return;
    ssize_t w = write(fd, b, (size_t)len);
    close(fd);
    if (w == len) rename(tmp, path);
}

static void publish(unsigned n)
{
    char b[16];
    write_small(SHUTTER_FILE, b, snprintf(b, sizeof b, "%u\n", n));
}

/* camera-service 51b9e02f…6a52d, X2DCameraStateMachine::setFullPressActive(bool). */
#define FULL_VA 0x15a7e8u
static const uint32_t full_prologue[4] = {0xd10243ff, 0xa9067bfd, 0x910183fd, 0xa90757f6};
static bool full_held;

/* In place of the state machine's setFullPressActive, on its thread. Never reaches the
 * original: this service runs only for the video session, where a still is never wanted. */
static void full_press(void *fsm, bool on)
{
    (void)fsm;
    if (!on) { full_held = false; return; }
    if (full_held) return;
    full_held = true;
    if (!x2v_session_guard()) {
        fprintf(stderr, "X2V_RESIDENT shutter press dropped (no session)\n");
        return;
    }
    unsigned n = atomic_fetch_add(&presses, 1) + 1;
    publish(n);
    fprintf(stderr, "X2V_RESIDENT shutter press=%u (native)\n", n);
}

static int find_service(struct dl_phdr_info *info, size_t size, void *out)
{
    (void)size;
    const char *n = info->dlpi_name ? strrchr(info->dlpi_name, '/') : NULL;
    if (!n || strcmp(n, "/camera-service")) return 0;
    *(uintptr_t *)out = info->dlpi_addr;
    return 1;
}

/* Before the service's main: no thread of its own runs yet. This domain may make the text page
 * RWX; RW and then back to RX is refused (that needs execmod). */
__attribute__((constructor)) static void full_press_install(void)
{
    uintptr_t base = 0;
    dl_iterate_phdr(find_service, &base);
    if (!base) return;
    uint32_t *p = (uint32_t *)(base + FULL_VA);
    if (memcmp(p, full_prologue, sizeof full_prologue)) {
        fprintf(stderr, "X2V_RESIDENT full_press entry mismatch %08x %08x\n", p[0], p[1]);
        return;
    }
    void *page = (void *)((uintptr_t)p & ~(uintptr_t)4095);
    if (mprotect(page, 4096, PROT_READ | PROT_WRITE | PROT_EXEC)) {
        fprintf(stderr, "X2V_RESIDENT full_press mprotect errno=%d\n", errno);
        return;
    }
    /* ldr x16, #8; br x16; .quad full_press */
    uint64_t target = (uintptr_t)&full_press;
    const uint32_t jump[2] = {0x58000050, 0xd61f0200};
    memcpy(p + 2, &target, sizeof target);
    memcpy(p, jump, sizeof jump);
    __builtin___clear_cache((char *)p, (char *)(p + 4));
    int e = mprotect(page, 4096, PROT_READ | PROT_EXEC) ? errno : 0;
    write_small(GATE_FILE, "1\n", 2);
    fprintf(stderr, "X2V_RESIDENT full_press installed at %p rx_errno=%d\n", (void *)p, e);
}

/* RTLD_NEXT finds nothing past this library for libevdev, which camera-service loads itself:
 * the loaded library is asked directly. This library exports a dlsym of its own, so the
 * loader's is called. */
static void *real_evdev(const char *name, const void *caller)
{
    void *p = __loader_dlsym(RTLD_NEXT, name, caller);
    const char *how = "next";
    if (!p) {
        void *h = dlopen("libevdev.so", RTLD_NOW | RTLD_NOLOAD);
        p = h ? __loader_dlsym(h, name, caller) : NULL;
        how = "noload";
    }
    fprintf(stderr, "X2V_RESIDENT shutter_gate %s=%p via=%s\n", name, p, how);
    return p;
}

int libevdev_next_event(struct libevdev *dev, unsigned int flags, struct input_event *ev);
int libevdev_next_event(struct libevdev *dev, unsigned int flags, struct input_event *ev)
{
    typedef int (*fn)(struct libevdev *, unsigned int, struct input_event *);
    static fn real;
    static unsigned logged;
    if (!real) {
        void *p = real_evdev("libevdev_next_event", (void *)&libevdev_next_event);
        memcpy(&real, &p, sizeof p);
        if (!real) return -ENOSYS;
    }
    int rc = real(dev, flags, ev);
    /* 0: an event, 1: an event while resyncing; anything else is no event. */
    if ((rc == 0 || rc == 1) && ev->type == EV_KEY && logged < 40) {
        logged++;
        fprintf(stderr, "X2V_RESIDENT key code=%u value=%d guard=%d\n", ev->code, ev->value, x2v_session_guard());
    }
    return rc;
}

int libevdev_uinput_write_event(const struct libevdev_uinput *u, unsigned int type, unsigned int code, int value);
int libevdev_uinput_write_event(const struct libevdev_uinput *u, unsigned int type, unsigned int code, int value)
{
    typedef int (*fn)(const struct libevdev_uinput *, unsigned int, unsigned int, int);
    static fn real;
    static unsigned logged;
    if (!real) {
        void *p = real_evdev("libevdev_uinput_write_event", (void *)&libevdev_uinput_write_event);
        memcpy(&real, &p, sizeof p);
        if (!real) return -ENOSYS;
    }
    /* Which way the physical shutter comes is told by these lines. */
    if (type == EV_KEY && logged < 60) {
        logged++;
        fprintf(stderr, "X2V_RESIDENT uinput key code=%u value=%d guard=%d\n", code, value, x2v_session_guard());
    }
    if (type == EV_KEY && code == KEY_E) {
        if (value == 1 && x2v_session_guard()) {
            held = 1;
            unsigned n = atomic_fetch_add(&presses, 1) + 1;
            publish(n);
            fprintf(stderr, "X2V_RESIDENT shutter press=%u (forwarded)\n", n);
            return 0;
        }
        /* A press the GUI got keeps its repeats and release; a swallowed one loses them. */
        if (held) {
            if (value == 0) held = 0;
            return 0;
        }
    }
    return real(u, type, code, value);
}
