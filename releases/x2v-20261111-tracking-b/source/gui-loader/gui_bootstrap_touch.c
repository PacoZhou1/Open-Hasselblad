/* X2D II 1.3.16.2 only. One manually launched process; no boot/file patches.
 * Interpose Bionic's main trampoline after ELF constructors. Replace only the
 * AppMain QString prefix; Qt's original resource registries remain intact.
 */
typedef unsigned long size_t;
typedef unsigned long uintptr_t;
typedef long ssize_t;
struct dl_phdr_info { uintptr_t base; const char *name; const void *phdr; unsigned short phnum; };
extern int dl_iterate_phdr(int (*)(struct dl_phdr_info *, size_t, void *), void *);
extern void *dlsym(void *, const char *);
extern char *getenv(const char *);
extern int strcmp(const char *, const char *);
extern int memcmp(const void *, const void *, size_t);
extern int open(const char *, int, ...);
extern ssize_t read(int, void *, size_t);
extern ssize_t write(int, const void *, size_t);
extern ssize_t readlink(const char *, char *, size_t);
extern int close(int);
extern void _exit(int) __attribute__((noreturn));

typedef int (*main_fn)(int, char **, char **);
typedef void (*libc_init_fn)(void *, void (*)(void), main_fn, const void *);
static main_fn original_main;
static const unsigned short stock_prefix[] = u"qrc:/qt/qml/app/qml/";
static const unsigned short custom_prefix[] = u"file:///blackbox/x2v-native-20261011/gui-tracking-b/";
struct qstring { void *d; const unsigned short *ptr; long length; };

static void status(const char *s) {
    size_t n=0; while(s[n]) ++n;
    int fd=open("/blackbox/x2v-native-20261011/bootstrap-tracking-b.log",1|64|1024,0600);
    if(fd>=0) { (void)write(fd,s,n); (void)close(fd); }
}
static int main_image(struct dl_phdr_info *p, size_t n, void *out) {
    (void)n;
    if(!p->name || !p->name[0] || !strcmp(p->name,"/system/bin/camera-gui")) {
        *(uintptr_t *)out=p->base; return 1;
    }
    return 0;
}
static uintptr_t fingerprint(const unsigned char *p) {
    uintptr_t h=14695981039346656037UL;
    for(size_t i=0;i<64;i++) h=(h^p[i])*1099511628211UL;
    return h;
}
static int wrapped_main(int argc, char **argv, char **envp) {
    char exe[128]; ssize_t n=readlink("/proc/self/exe",exe,sizeof(exe)-1);
    if(n<=0 || n>=(ssize_t)sizeof(exe)-1) return original_main(argc,argv,envp);
    exe[n]=0;
    const char *enabled=getenv("X2V_GUI_ENABLE");
    if(!enabled || strcmp(enabled,"1") || strcmp(exe,"/system/bin/camera-gui"))
        return original_main(argc,argv,envp);
    uintptr_t base=0; dl_iterate_phdr(main_image,&base);
    if(!base || fingerprint((const unsigned char *)(base+0x40ebc4UL))!=0x035f9b03390179ccUL) {
        status("BUILD_MISMATCH_NO_CHANGE\n"); return original_main(argc,argv,envp);
    }
    struct qstring *prefix=(struct qstring *)(base+0x2b054b8UL);
    if(prefix->d || prefix->ptr!=(const unsigned short *)(base+0x1cedb5cUL) ||
       prefix->length!=(long)(sizeof(stock_prefix)/2-1) ||
       memcmp(prefix->ptr,stock_prefix,sizeof(stock_prefix))) {
        status("PREFIX_MISMATCH_NO_CHANGE\n"); return original_main(argc,argv,envp);
    }
    const char *dry=getenv("X2V_GUI_DRY_RUN");
    if(dry && !strcmp(dry,"1")) { status("DRY_RUN_BUILD_PREFIX_VERIFIED\n"); return 0; }
    prefix->d=0; prefix->ptr=custom_prefix; prefix->length=sizeof(custom_prefix)/2-1;
    __asm__ __volatile__("dmb ish" ::: "memory");
    status("TEMPORARY_MAIN_PREFIX_INSTALLED\n");
    return original_main(argc,argv,envp);
}
__attribute__((visibility("default"),noreturn))
void __libc_init(void *args, void (*onexit)(void), main_fn main, const void *structors) {
    libc_init_fn real=(libc_init_fn)dlsym((void *)-1,"__libc_init");
    if(!real) {status("LIBC_INIT_NOT_FOUND\n"); _exit(127);}
    original_main=main;
    real(args,onexit,wrapped_main,structors);
    _exit(127);
}
__attribute__((constructor)) static void loaded(void) { status("BOOTSTRAP_LIBRARY_LOADED\n"); }
