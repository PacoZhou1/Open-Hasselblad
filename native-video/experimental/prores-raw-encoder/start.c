/* Minimal dynamic Bionic startup: Android9 crtbegin.c/libc_init_dynamic.cpp
 * require raw kernel arguments, main and a three-pointer structors record.
 * No custom constructor/destructor. See reference/ for primary source. */
struct structors {void (**preinit)(void),(**init)(void),(**fini)(void);};
extern int main(int,char**,char**);
extern void __libc_init(void*,void(*)(void),int(*)(int,char**,char**),const struct structors*) __attribute__((noreturn));
__attribute__((used,noinline)) static void x2v_start_main(void *arguments){
 static const struct structors empty={0,0,0};
 __libc_init(arguments,0,main,&empty);
}
__asm__(".text; .global _start; .hidden _start; .type _start,%function; _start: mov x0,sp; b x2v_start_main; .size _start,.-_start");
