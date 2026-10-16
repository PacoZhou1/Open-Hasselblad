#define _GNU_SOURCE 1
#include <stdio.h>
#include <dlfcn.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <stdatomic.h>
#include <errno.h>
#include "getter_pins.h"
/* Android Bionic libdl dlsym@f28 supplies callerPC in x2 to exported
 * linker64 __loader_dlsym@14468. Do NOT use this Android entry on host. */
extern void *__loader_dlsym(void *,const char *,const void *);
static void *loader(void *h,const char *name,const void *pc){return __loader_dlsym(h,name,pc);}
typedef int (*cam_info_fn)(void *,void *,int *);
static _Atomic(cam_info_fn) original_info;
static _Atomic unsigned sp_reads,conf_reads,owned_infos;
#ifndef X2V_ENABLE_MODE21_PROFILE
#define X2V_ENABLE_MODE21_PROFILE 0
#endif
static int enabled_stage(const char *s){
 if(!s)return 0;
 if(!strcmp(s,"normal"))return 1;
 const char *owner=getenv("X2V_SOURCE_ADAPTER");
 return X2V_ENABLE_MODE21_PROFILE && !strcmp(s,"mode21-c24") && owner && !strcmp(owner,"mode21-c-24fps");
}
int x2v_graph_parser_ready(void){return atomic_load(&sp_reads)>0&&atomic_load(&conf_reads)>0&&atomic_load(&owned_infos)>0;}

/* Implemented by HAL topology/profile glue; CPU-owned data only. */
extern int x2v_apply_owned_cam_info(void *cam_info,const char *stage);
static int owned_info(void *cfg,void *out,int *count){
 cam_info_fn f=atomic_load(&original_info);if(!f)return -ENOSYS;
 int e=f(cfg,out,count);if(e)return e;
 const char *stage=getenv("X2V_OWNED_RAW_GRAPH");
 if(!enabled_stage(stage))return 0; /* stream execution is separately gated. */
 if(!count||*count<0||*count>2)return -EPROTO;
 for(int i=0;i<*count;i++){
  unsigned char *c=(unsigned char*)out+i*0x1580;
  if(!strcmp((char*)c,"hb722_imx861bqr_cam")){
   e=x2v_apply_owned_cam_info(c,stage);if(e)return -e;atomic_fetch_add(&owned_infos,1);
  }
 }
 return 0;
}
static int target_getter(void *p){
 Dl_info info={0};if(!p||!dladdr(p,&info)||!info.dli_fname||!info.dli_fbase)return 0;
 const char *b=strrchr(info.dli_fname,'/');b=b?b+1:info.dli_fname;
 if(strcmp(b,"libdcam_cam_info_e2_hb722.so"))return 0;
 /* First PT_LOAD VA1000/offset0: dli_fbase is the mapped ELF header,
  * not the load bias. Whole ELF SHA is an external root readback gate;
  * exact getter VA+64 instruction bytes additionally reject wrong builds. */
 if((uintptr_t)p!=(uintptr_t)info.dli_fbase-X2V_HAL_FIRST_LOAD_VA+X2V_GETTER_VA || info.dli_saddr!=p || memcmp(p,x2v_getter_code,sizeof x2v_getter_code))return 0;
 return 1;
}
void *dlsym(void *h,const char *name){
 void *p=loader(h,name,__builtin_return_address(0));
 const char *stage=getenv("X2V_OWNED_RAW_GRAPH");
 if(p && enabled_stage(stage) && !strcmp(name,"get_cam_info") && target_getter(p)){
  cam_info_fn f;memcpy(&f,&p,sizeof f);cam_info_fn expected=NULL;
  if(!atomic_compare_exchange_strong(&original_info,&expected,f) && expected!=f){
   fprintf(stderr,"X2V_GRAPH reject second HAL getter address\n");return p;
  }
  f=owned_info;memcpy(&p,&f,sizeof p);
 }
 return p;
}
/* Both /etc and /system/etc are exact stock parser paths. No global arbitrary
 * path replacement; only readonly .sp/.conf input FDs5/6. No firmware writes. */
static int graph_fd(const char *path){
 const char *stage=getenv("X2V_OWNED_RAW_GRAPH");
 if(!path||!enabled_stage(stage))return -1;
 if(!strcmp(path,"/etc/imx861bqr_hb722.sp")||!strcmp(path,"/system/etc/imx861bqr_hb722.sp"))return 5;
 if(!strcmp(path,"/etc/imx861bqr_hb722.conf")||!strcmp(path,"/system/etc/imx861bqr_hb722.conf"))return 6;
 return -1;
}
static int proc_path(int fd,char out[32]){
 struct stat s;int fl=fcntl(fd,F_GETFL);
 if(fl<0||fstat(fd,&s)||!S_ISREG(s.st_mode)||s.st_size<=0||s.st_size>2*1024*1024||(fl&O_ACCMODE)!=O_RDONLY){errno=EINVAL;return -1;}
 snprintf(out,32,"/proc/self/fd/%d",fd);return 0;
}
/* Actual .sp reader calls __open_2(path,0) at frwk24d514. Opening the
 * proc FD path creates a NEW open-file description; do not dup/lseek an
 * inherited parser FD. Repeated/concurrent reads have independent offsets. */
int __open_2(const char *path,int flags){
 typedef int (*fn)(const char *,int);
 void *p=loader(RTLD_NEXT,"__open_2",(const void *)&__open_2);fn real;memcpy(&real,&p,sizeof p);
 if(!real){errno=ENOSYS;return -1;}
 int fd=graph_fd(path);
 if(fd>=0){
  if(flags!=O_RDONLY){errno=EINVAL;return -1;}
  char proc[32];if(proc_path(fd,proc))return -1;
  fprintf(stderr,"X2V_GRAPH parser redirect %s -> FD%d independent-open\n",path,fd);
  int got=real(proc,flags);if(got>=0)atomic_fetch_add(fd==5?&sp_reads:&conf_reads,1);return got;
 }
 return real(path,flags);
}
FILE *fopen(const char *path,const char *mode){
 typedef FILE *(*fn)(const char *,const char *);
 void *p=loader(RTLD_NEXT,"fopen",(const void *)&fopen);fn real;memcpy(&real,&p,sizeof p);
 if(!real)return NULL;
 int fd=graph_fd(path);
 if(fd>=0){
  /* Actual text_setting_file path: base8c1fc fopen(path,"r"). */
  if(!mode||strcmp(mode,"r")){errno=EINVAL;return NULL;}
  char proc[32];if(proc_path(fd,proc))return NULL;
  fprintf(stderr,"X2V_GRAPH parser redirect %s -> FD%d independent-open\n",path,fd);
  FILE *got=real(proc,mode);if(got)atomic_fetch_add(fd==5?&sp_reads:&conf_reads,1);return got;
 }
 return real(path,mode);
}
