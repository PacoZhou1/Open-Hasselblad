#define _GNU_SOURCE 1
#include "io_provider.h"
#include <dlfcn.h>
#include <errno.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
typedef ssize_t(*pwrite_fn)(int,const void*,size_t,off_t);
typedef int(*fsync_fn)(int);
static pwrite_fn native_pwrite;
static fsync_fn native_fsync;
static void*libc_reference;
static uintptr_t provider_base,pwrite_address,fsync_address;
static int provider_pinned;
static const unsigned char pins[2][24]={
 {0x88,0x08,0x80,0xd2,0x01,0x00,0x00,0xd4,0x1f,0x04,0x40,0xb1,0x00,0x94,0x80,0xda,0xc8,0x9b,0xff,0x54,0xc0,0x03,0x5f,0xd6},
 {0x48,0x0a,0x80,0xd2,0x01,0x00,0x00,0xd4,0x1f,0x04,0x40,0xb1,0x00,0x94,0x80,0xda,0xc8,0xc5,0xff,0x54,0xc0,0x03,0x5f,0xd6}
};
int x2v_writer_provider_bind(void){
 if(provider_pinned)return 0;
 libc_reference=dlopen("/system/lib64/libc.so",RTLD_NOW|RTLD_NOLOAD);if(!libc_reference)return EINVAL;
 const char*names[2]={"pwrite","fsync"};uintptr_t offsets[2]={0x70c40,0x70700},base=0;void*found[2]={0};
 for(unsigned k=0;k<2;k++){
  Dl_info d={0};found[k]=dlsym(libc_reference,names[k]);
  if(!found[k]||!dladdr(found[k],&d)||!d.dli_fname||!d.dli_sname||!d.dli_fbase||
   strcmp(d.dli_fname,"/system/lib64/libc.so")||strcmp(d.dli_sname,names[k])||d.dli_saddr!=found[k]||
   (uintptr_t)found[k]<(uintptr_t)d.dli_fbase||(uintptr_t)found[k]-(uintptr_t)d.dli_fbase!=offsets[k]||
   (k&&(uintptr_t)d.dli_fbase!=base))return EINVAL;
  base=(uintptr_t)d.dli_fbase;const unsigned char*code=found[k];
  for(unsigned i=0;i<24;i++)if(code[i]!=pins[k][i])return EINVAL;
 }
 union{void*object;pwrite_fn function;}w={.object=found[0]};union{void*object;fsync_fn function;}s={.object=found[1]};
 native_pwrite=w.function;native_fsync=s.function;provider_base=base;pwrite_address=(uintptr_t)found[0];fsync_address=(uintptr_t)found[1];provider_pinned=1;return 0;
}
int x2v_writer_provider_pinned(void){return provider_pinned;}
ssize_t x2v_writer_pwrite(int fd,const void*p,size_t n,off_t o){if(!provider_pinned||!native_pwrite){errno=EINVAL;return -1;}return native_pwrite(fd,p,n,o);}
int x2v_writer_fsync(int fd){if(!provider_pinned||!native_fsync){errno=EINVAL;return -1;}return native_fsync(fd);}
size_t x2v_writer_provider_json(char*out,size_t cap){
 int n=snprintf(out,cap,"\"writer_provider_pinned\":%d,\"writer_provider_kind\":%d,\"writer_provider_path\":\"%s\",\"writer_provider_base\":%llu,\"writer_provider_pwrite_offset\":%llu,\"writer_provider_pwrite_address\":%llu,\"writer_provider_fsync_offset\":%llu,\"writer_provider_fsync_address\":%llu",provider_pinned,provider_pinned?1:0,provider_pinned?"/system/lib64/libc.so":"",(unsigned long long)provider_base,(unsigned long long)(pwrite_address-provider_base),(unsigned long long)pwrite_address,(unsigned long long)(fsync_address-provider_base),(unsigned long long)fsync_address);
 return n>0&&(size_t)n<cap?(size_t)n:0;
}
