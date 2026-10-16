#define _GNU_SOURCE 1
#include "copy_provider.h"
#include "copy_provider_pin.h"
#include <dlfcn.h>
#include <errno.h>
#include <string.h>
#include <stdint.h>
#include <stdio.h>
typedef void *(*copy_fn)(void *,const void *,size_t);
static copy_fn native_copy;
static void *libc_reference;
static int provider_pinned;
static uintptr_t provider_base,provider_address;
int x2v_copy_provider_bind(void){
 if(provider_pinned)return 0;
 /* Already present in every Bionic process; NOLOAD avoids initializing an
  * absent library. The reference is retained for process lifetime. */
 libc_reference=dlopen("/system/lib64/libc.so",RTLD_NOW|RTLD_NOLOAD);
 if(!libc_reference)return EINVAL;
 union {void *object;copy_fn function;} found;
 found.object=dlsym(libc_reference,"memcpy");Dl_info info={0};
 if(!found.object||!dladdr(found.object,&info)||!info.dli_fname||!info.dli_sname||
    strcmp(info.dli_fname,"/system/lib64/libc.so")||strcmp(info.dli_sname,"memcpy")||
    info.dli_saddr!=found.object||!info.dli_fbase||
    (uintptr_t)found.object<(uintptr_t)info.dli_fbase)return EINVAL;
 const unsigned char *code=found.object;
 for(size_t i=0;i<sizeof x2v_native_memcpy_pin;i++)if(code[i]!=x2v_native_memcpy_pin[i])return EINVAL;
 native_copy=found.function;provider_base=(uintptr_t)info.dli_fbase;
 provider_address=(uintptr_t)found.object;provider_pinned=1;return 0;
}
size_t x2v_copy_provider_json(char*out,size_t cap){
 /* CPU controller/main only; never runs in a borrowed callback. */
 int n=snprintf(out,cap,"\"copy_provider_pinned\":%d,\"copy_provider_kind\":%d,\"copy_provider_path\":\"%s\",\"copy_provider_base\":%llu,\"copy_provider_offset\":%llu,\"copy_provider_address\":%llu",provider_pinned,provider_pinned?1:0,provider_pinned?"/system/lib64/libc.so":"",(unsigned long long)provider_base,(unsigned long long)(provider_address-provider_base),(unsigned long long)provider_address);
 return n>0&&(size_t)n<cap?(size_t)n:0;
}
int x2v_copy_provider_pinned(void){return provider_pinned;}
int x2v_copy_bytes(void*dst,const void*src,size_t n){
 /* Immutable after constructor/main; callback performs only the cached call. */
 if(!provider_pinned||!native_copy||!dst||!src)return EINVAL;
 return native_copy(dst,src,n)==dst?0:EIO;
}
