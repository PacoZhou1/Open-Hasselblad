#define _GNU_SOURCE 1
#define X2V_HOST_TEST 1
#ifndef O_DIRECT
#define O_DIRECT 65536
#endif
#include <assert.h>
#include <stdatomic.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <pthread.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdarg.h>
static int host_fcntl(int,int,...);
#define fcntl host_fcntl
#include "receiver.c"
#undef fcntl
#include "vendor_hook.c"
static void seal_barrier(void*);
static void between_clips(void);
#define X2V_BEFORE_FINAL_COMMAND(c) seal_barrier(c)
#define X2V_BETWEEN_CLIPS() between_clips()
#include "control.c"
static const char*scenario;
static void between_clips(void){
 if(!strcmp(scenario,"expiry-between-clips")){
  assert(x2v_receiver_capture_success(clips[0].receiver)&&x2v_receiver_cpu_drained(clips[0].receiver));
  uint64_t past=x2v_receiver_millis()-1;
  constructor_deadline=past;x2v_receiver_set_deadline(clips[1].receiver,past);
 }
}
static int direct_fd[4096];
static _Atomic int hold_write,inside_write;
int test_openat(int d,const char*n,int f,mode_t m){int fd=openat(d,n,f&~O_DIRECT,m);if(fd>=0){assert(fd<4096);direct_fd[fd]=!!(f&O_DIRECT);}return fd;}
int test_getfl(int fd){int f=fcntl(fd,F_GETFL);return f>=0&&direct_fd[fd]?f|O_DIRECT:f;}
int test_close(int fd){direct_fd[fd]=0;return close(fd);}

static _Atomic unsigned maps,unmaps,forwarded,hold_original,inside_original;
static void*source;
static int host_fcntl(int fd,int op,...){
 assert(fd>=0&&fd<4096);
 if(op==F_DUPFD_CLOEXEC){va_list ap;va_start(ap,op);int n=va_arg(ap,int);va_end(ap);int out=fcntl(fd,op,n);assert(out<4096);if(out>=0)direct_fd[out]=direct_fd[fd];return out;}
 if(op==F_SETFL){va_list ap;va_start(ap,op);int f=va_arg(ap,int);va_end(ap);direct_fd[fd]=!!(f&O_DIRECT);return fcntl(fd,op,f&~O_DIRECT);}
 int value=fcntl(fd,op);return op==F_GETFL&&value>=0&&direct_fd[fd]?value|O_DIRECT:value;
}
int x2v_copy_provider_bind(void){return 0;}
int x2v_copy_provider_pinned(void){return 1;}
int x2v_copy_bytes(void*d,const void*s,size_t n){memcpy(d,s,n);return 0;}
int x2v_writer_provider_bind(void){return 0;}
int x2v_writer_provider_pinned(void){return 1;}
ssize_t x2v_writer_pwrite(int fd,const void*p,size_t n,off_t off){
 if(!strcmp(scenario,"second-write-error")&&direct_fd[fd]&&x2v_receiver_capture_armed(clips[1].receiver)){errno=EIO;return -1;}
 if(direct_fd[fd]&&atomic_load(&hold_write)){atomic_store(&inside_write,1);while(atomic_load(&hold_write))usleep(1000);}
 return pwrite(fd,p,n,off);
}
int x2v_writer_fsync(int fd){return fsync(fd);}
size_t x2v_copy_provider_json(char*out,size_t n){int r=snprintf(out,n,"\"copy_provider_pinned\":1,\"copy_provider_kind\":1,\"copy_provider_path\":\"/system/lib64/libc.so\",\"copy_provider_base\":1000000,\"copy_provider_offset\":124304,\"copy_provider_address\":1124304");return r>0&&(size_t)r<n?(size_t)r:0;}
size_t x2v_writer_provider_json(char*out,size_t n){int r=snprintf(out,n,"\"writer_provider_pinned\":1,\"writer_provider_kind\":1,\"writer_provider_path\":\"/system/lib64/libc.so\",\"writer_provider_base\":1000000,\"writer_provider_pwrite_offset\":461888,\"writer_provider_pwrite_address\":1461888,\"writer_provider_fsync_offset\":460544,\"writer_provider_fsync_address\":1460544");return r>0&&(size_t)r<n?(size_t)r:0;}
int duss_hal_mem_get_flags(void*h,uint32_t*v){assert(h==(void*)0x1234);*v=17;return 0;}
int duss_hal_mem_get_fd(void*h,int*v){assert(h==(void*)0x1234);*v=42;return 0;}
int duss_hal_mem_get_size(void*h,uint32_t*n){assert(h==(void*)0x1234);*n=X2V_BYTES;return 0;}
int duss_hal_mem_map(void*h,void**p){assert(h==(void*)0x1234);atomic_fetch_add(&maps,1);*p=source;return 0;}
int duss_hal_mem_sync_ext(void*h,unsigned f,unsigned o,uint64_t n){assert(h==(void*)0x1234&&f==1&&o==0&&n==X2V_BYTES);return 0;}
int duss_hal_mem_unmap(void*h){assert(h==(void*)0x1234);atomic_fetch_add(&unmaps,1);return 0;}
static void native_original(const char*n,const char*p,void*c,void*f){
 assert(n&&p&&c==(void*)0x9876&&f);atomic_fetch_add(&forwarded,1);
 if(atomic_load(&hold_original)){atomic_store(&inside_original,1);while(atomic_load(&hold_original))usleep(1000);}
}
static void seal_barrier(void*v){struct clip_control*c=v;if(!strcmp(scenario,"late-D")&&c->generation==1){assert(x2v_receiver_cpu_drained(c->receiver));assert(pwrite(command_fd,"D",1,0)==1);}}
static void set32(void*f,unsigned o,uint32_t v){memcpy((char*)f+o,&v,4);}static void set64(void*f,unsigned o,uint64_t v){memcpy((char*)f+o,&v,8);}
static void emit(unsigned generation,unsigned index){
 unsigned char frame[0x3b0]={0};memset(source,0x20+generation*0x10+index,X2V_BYTES);
 set64(frame,0x20,0x1234);set32(frame,0x28,X2V_PIXEL);set32(frame,0x38,X2V_WIDTH);set32(frame,0x3c,X2V_HEIGHT);set32(frame,0x40,X2V_STRIDE);set32(frame,0x4c,X2V_HEIGHT);set32(frame,0xb0,1);
 set32(frame,0xb4,generation*100+index);set64(frame,0x30,generation*1000000+index*50000);
 cam_filter_dump_frame_data(X2V_NAME,X2V_PORT,(void*)0x9876,frame);
}
static void*emit_second(void*v){(void)v;emit(1,1);return NULL;}
static void wait_written(struct x2v_receiver*c,unsigned n){for(unsigned i=0;i<5000&&atomic_load(&c->written)<n;i++)usleep(1000);assert(atomic_load(&c->written)==n);}
static void wait_armed(struct x2v_receiver*c){for(unsigned i=0;i<5000&&!x2v_receiver_capture_armed(c);i++)usleep(1000);assert(x2v_receiver_capture_armed(c));}
static void wait_ack(int fd){char last=0;struct stat st;for(unsigned i=0;i<10000;i++){assert(!fstat(fd,&st));if(st.st_size&&pread(fd,&last,1,st.st_size-1)==1&&last=='\n')return;usleep(1000);}assert(!"ack timeout");}
static int create_dir(const char*directory,const char*name){char p[1024];assert(snprintf(p,sizeof p,"%s/%s",directory,name)>0);assert(!mkdir(p,0700));int fd=open(p,O_RDONLY|O_DIRECTORY);assert(fd>=0);return fd;}
static int create(const char*directory,const char*name){char p[1024];assert(snprintf(p,sizeof p,"%s/%s",directory,name)>0);int fd=open(p,O_CREAT|O_EXCL|O_RDWR,0600);assert(fd>=0);return fd;}
static int check_fixed_fds(const char *directory){
 int vals[5],fixed[5]={7,3,4,8,9};
 int cmd=create(directory,"command");assert(write(cmd,"0",1)==1);
 char path[1024];snprintf(path,sizeof path,"%s/command",directory);
 int ro=open(path,O_RDONLY);assert(ro>=0);
 vals[0]=fcntl(!strcmp(scenario,"fd-command-writable")?cmd:ro,F_DUPFD_CLOEXEC,100);assert(vals[0]>=100);close(cmd);close(ro);
 for(unsigned i=1;i<5;i++){
  int fd;
  if(i<=2){fd=create_dir(directory,i==1?"out1":"out2");}
  else fd=create(directory,i==3?"ack1":"ack2");
  vals[i]=fcntl(fd,F_DUPFD_CLOEXEC,100);assert(vals[i]>=100);close(fd);
 }
 if(!strcmp(scenario,"fd-alias-output")){close(vals[2]);vals[2]=fcntl(vals[1],F_DUPFD_CLOEXEC,100);}
 if(!strcmp(scenario,"fd-regular-output")){close(vals[1]);int fd=create(directory,"wrong-regular");vals[1]=fcntl(fd,F_DUPFD_CLOEXEC,100);close(fd);}
 for(unsigned i=0;i<5;i++)assert(dup2(vals[i],fixed[i])==fixed[i]);
 int e=control_fds();assert(e==(!strcmp(scenario,"fd-valid")?0:EINVAL));
 if(!e){assert(command_fd>=10);close(command_fd);for(unsigned i=0;i<2;i++){close(clips[i].output_fd);close(clips[i].ack_fd);}}
 for(unsigned i=0;i<5;i++){close(vals[i]);close(fixed[i]);}
 fprintf(stderr,"PASS %s actual fixed-FD directory contract\n",scenario);return 0;
}
int main(int argc,char**argv){
 assert(argc==3);(void)control_fds;scenario=argv[1];const char*directory=argv[2];int output[2],receipts[2];
 if(!strncmp(scenario,"fd-",3))return check_fixed_fds(directory);
 source=malloc(X2V_BYTES);assert(source);original=native_original;pinned=got_is_hook=1;
 command_fd=create(directory,"command");assert(write(command_fd,"0",1)==1);
 constructor_deadline=x2v_receiver_millis()+47000;
 for(unsigned i=0;i<2;i++){
  struct clip_control*c=&clips[i];c->generation=i+1;c->receiver=x2v_receiver_new(i+1,constructor_deadline);c->hook=x2v_hook_clip_new(c->receiver,i+1);assert(c->receiver&&c->hook);
  output[i]=create_dir(directory,i?"clip2":"clip1");receipts[i]=create(directory,i?"clip2.json":"clip1.json");
  c->output_fd=dup(output[i]);c->ack_fd=dup(receipts[i]);assert(c->output_fd>=0&&c->ack_fd>=0);
 }
 assert(clips[0].receiver!=clips[1].receiver);
 assert(!x2v_receiver_prepare_normal(clips[0].receiver,clips[0].output_fd)&&!x2v_hook_open(clips[0].hook));
 pthread_t control;assert(!pthread_create(&control,NULL,controller,NULL));
 if(!strcmp(scenario,"early-B")){assert(pwrite(command_fd,"B",1,0)==1);assert(!pthread_join(control,NULL));assert(!x2v_receiver_capture_success(clips[0].receiver)&&!x2v_receiver_capture_armed(clips[1].receiver));goto done;}
 assert(pwrite(command_fd,"A",1,0)==1);wait_armed(clips[0].receiver);
 if(!strcmp(scenario,"three-slot-stop")){
  atomic_store(&hold_write,1);emit(1,0);
  for(unsigned i=0;i<5000&&!atomic_load(&inside_write);i++)usleep(1000);assert(inside_write);
  emit(1,1);emit(1,2);
  assert(clips[0].receiver->copied==3&&clips[0].receiver->written==0);
  for(unsigned k=0;k<3;k++)assert(clips[0].receiver->slot_state[k]!=SLOT_FREE);
  assert(pwrite(command_fd,"S",1,0)==1);
  for(unsigned i=0;i<5000&&!clips[0].receiver->admission_closed;i++)usleep(1000);
  assert(clips[0].receiver->admission_closed&&!clips[0].receiver->cpu_drained);
  atomic_store(&hold_write,0);wait_ack(receipts[0]);
  assert(clips[0].receiver->written==3&&x2v_receiver_capture_success(clips[0].receiver));
  assert(pwrite(command_fd,"D",1,0)==1);assert(!pthread_join(control,NULL));goto done;
 }
 emit(1,0);wait_written(clips[0].receiver,1);
 if(!strcmp(scenario,"inflight-original")){
  atomic_store(&hold_original,1);pthread_t callback;assert(!pthread_create(&callback,NULL,emit_second,NULL));
  for(unsigned i=0;i<5000&&!atomic_load(&inside_original);i++)usleep(1000);assert(inside_original);
  assert(pwrite(command_fd,"S",1,0)==1);
  for(unsigned i=0;i<5000&&!x2v_clip_closed(&clips[0].hook->descriptor);i++)usleep(1000);
  /* Unmap publishes the independent CPU copy before original returns.
   * The hook lease, not the CPU slot state, prevents final pool release. */
  assert(clips[0].receiver->copied==2&&maps==unmaps);
  assert(x2v_clip_closed(&clips[0].hook->descriptor)&&x2v_receiver_callback_active(clips[0].hook)==1&&!x2v_receiver_cpu_drained(clips[0].receiver)&&clips[0].receiver->cpu_copy);
  atomic_store(&hold_original,0);assert(!pthread_join(callback,NULL));
 }else{emit(1,1);wait_written(clips[0].receiver,2);assert(pwrite(command_fd,"S",1,0)==1);}
 wait_ack(receipts[0]);
 if(!strcmp(scenario,"expiry-between-clips")){
  assert(!pthread_join(control,NULL));
  assert(x2v_receiver_capture_success(clips[0].receiver)&&!x2v_receiver_capture_armed(clips[1].receiver));
  assert(x2v_receiver_expired(clips[1].receiver)&&clips[1].receiver->prefault_bytes==0);
  goto done;
 }
 if(!strcmp(scenario,"late-D")){assert(!pthread_join(control,NULL));assert(!x2v_receiver_capture_success(clips[0].receiver)&&!x2v_receiver_capture_armed(clips[1].receiver));goto done;}
 for(unsigned i=0;i<5000&&x2v_clip_snapshot(&publication)!=&clips[1].hook->descriptor;i++)usleep(1000);
 assert(x2v_clip_snapshot(&publication)==&clips[1].hook->descriptor);
 assert(x2v_receiver_capture_success(clips[0].receiver)&&x2v_receiver_cpu_drained(clips[0].receiver));
 struct x2v_clip_lease old={0};assert(x2v_clip_enter_snapshot(&clips[0].hook->descriptor,&old)==EAGAIN&&!old.descriptor);
 assert(x2v_hook_open(clips[0].hook)==EBUSY);assert(!command(&clips[1],'A')&&!command(&clips[1],'S')&&!x2v_receiver_capture_armed(clips[1].receiver));
 if(!strcmp(scenario,"abort-between")){assert(pwrite(command_fd,"D",1,0)==1);assert(!pthread_join(control,NULL));assert(x2v_receiver_capture_success(clips[0].receiver)&&!x2v_receiver_capture_success(clips[1].receiver));goto done;}
 assert(pwrite(command_fd,"B",1,0)==1);wait_armed(clips[1].receiver);
 if(!strcmp(scenario,"stale-ticket")){
  struct x2v_ticket stale={.owner=clips[0].receiver,.clip_generation=1,.slot=0,.index=0,.generation=1};
  assert(x2v_receiver_copy_reserved(clips[1].receiver,&stale,source,X2V_BYTES)==EINVAL);
 }
 emit(2,0);
 if(!strcmp(scenario,"second-write-error")){assert(!pthread_join(control,NULL));assert(x2v_receiver_capture_success(clips[0].receiver)&&!x2v_receiver_capture_success(clips[1].receiver));goto done;}
 wait_written(clips[1].receiver,1);emit(2,1);wait_written(clips[1].receiver,2);assert(pwrite(command_fd,"T",1,0)==1);assert(!pthread_join(control,NULL));
 assert(x2v_receiver_capture_success(clips[0].receiver)&&x2v_receiver_capture_success(clips[1].receiver));
 assert(clips[0].receiver->copied==2&&clips[1].receiver->copied==2&&clips[1].receiver->records[0].write_offset==0);
 done:
 for(unsigned i=0;i<2;i++){assert(x2v_receiver_cpu_drained(clips[i].receiver)&&!x2v_receiver_callback_active(clips[i].hook)&&x2v_clip_quiescent(&clips[i].hook->descriptor));assert(!clips[i].receiver->cpu_copy);
 unsigned count=atomic_load(&clips[i].receiver->written);
 for(unsigned j=0;j<count;j++){
  char name[40];snprintf(name,sizeof name,"frame-%06u.dng",j);int fd=openat(output[i],name,O_RDONLY);assert(fd>=0);
  struct stat st;assert(!fstat(fd,&st)&&st.st_size==X2V_DNG_FILE_BYTES);
  unsigned char buf[7840];for(unsigned y=0;y<X2V_HEIGHT;y++){assert(pread(fd,buf,sizeof buf,4096+(off_t)y*7840)==sizeof buf);for(unsigned x=0;x<sizeof buf;x++)assert(buf[x]==0x20+(i+1)*0x10+j);}
  assert(!close(fd));
 }
 assert(!close(output[i])&&!close(receipts[i]));}
 assert(maps==unmaps&&x2v_clip_snapshot(&publication)==NULL);free(source);fprintf(stderr,"PASS %s maps=%u unmaps=%u forwarded=%u\n",scenario,atomic_load(&maps),atomic_load(&unmaps),atomic_load(&forwarded));return 0;
}
