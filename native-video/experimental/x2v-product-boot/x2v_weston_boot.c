/* Weston module whose only job is to start the X2V product supervisor at boot.
 *
 * weston runs as hbl_camera_service from its own init cgroup and is not restarted
 * by camera-service handoffs, so a child spawned here keeps that domain without an
 * exec transition (none is permitted for our files) and survives those handoffs.
 *
 * weston exits if wet_module_init fails, taking the display with it, so this
 * always returns 0 and never touches the compositor. */
#include <dirent.h>
#include <fcntl.h>
#include <signal.h>
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

#define ETC "/system/etc/x2v"
#define PREFIX "x2v_product_boot_"
#define DISABLE "/blackbox/x2v-native-20261011/product/disable"
#define LOG "/blackbox/x2v-native-20261011/product/weston-module.log"

struct weston_compositor;

static void note(const char *what)
{
    int fd = open(LOG, O_WRONLY | O_CREAT | O_APPEND | O_CLOEXEC, 0644);
    if (fd < 0)
        return;
    char line[160];
    int n = snprintf(line, sizeof line, "%s pid=%d\n", what, (int)getpid());
    if (n > 0)
        (void)!write(fd, line, (size_t)n);
    close(fd);
}

__attribute__((visibility("default")))
int wet_module_init(struct weston_compositor *compositor, int *argc, char *argv[])
{
    (void)compositor; (void)argc; (void)argv;
    if (access(DISABLE, F_OK) == 0) {
        note("disabled");
        return 0;
    }
    /* Supervisors are installed as new versioned files, never rewritten: the newest name wins. */
    char supervisor[256] = "";
    DIR *dir = opendir(ETC);
    if (dir) {
        struct dirent *d;
        char best[128] = "";
        while ((d = readdir(dir))) {
            size_t n = strlen(d->d_name);
            if (n < sizeof best && !strncmp(d->d_name, PREFIX, sizeof PREFIX - 1) &&
                n > 3 && !strcmp(d->d_name + n - 3, ".sh") && strcmp(d->d_name, best) > 0)
                memcpy(best, d->d_name, n + 1);
        }
        closedir(dir);
        if (best[0])
            snprintf(supervisor, sizeof supervisor, ETC "/%s", best);
    }
    if (!supervisor[0] || access(supervisor, R_OK) != 0) {
        note("supervisor_missing");
        return 0;
    }
    pid_t child = fork();
    if (child < 0) {
        note("fork_failed");
        return 0;
    }
    if (child == 0) {
        /* Grandchild is reparented to init, so weston's SIGCHLD handling never sees it. */
        if (fork() != 0)
            _exit(0);
        setsid();
        /* weston blocks signals it routes through signalfd; exec keeps the mask. */
        sigset_t none;
        sigemptyset(&none);
        sigprocmask(SIG_SETMASK, &none, NULL);
        for (int sig = 1; sig < NSIG; sig++)
            signal(sig, SIG_DFL);
        for (int fd = 3; fd < 1024; fd++)
            close(fd);
        int in = open("/dev/null", O_RDONLY);
        if (in >= 0 && in != 0) { dup2(in, 0); close(in); }
        int out = open("/blackbox/x2v-native-20261011/product/supervisor.out",
                       O_WRONLY | O_CREAT | O_APPEND, 0644);
        if (out >= 0) { dup2(out, 1); dup2(out, 2); if (out > 2) close(out); }
        execl("/system/bin/sh", "sh", supervisor, (char *)NULL);
        _exit(127);
    }
    /* weston's own SIGCHLD reaper may collect it first; either way it is gone. */
    (void)waitpid(child, NULL, 0);
    note("spawned");
    return 0;
}
