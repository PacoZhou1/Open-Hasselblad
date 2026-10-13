#define _GNU_SOURCE 1
#include "receiver.h"
#include "shape.h"
#include "hook.h"
#include "metadata_binding.h"
#include "copy_provider.h"
#include "io_provider.h"
#include "dng_prepacked.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <pthread.h>
#include <errno.h>
/* Fixed two-clip integration proof, not unlimited product recording. */
struct clip_control {struct x2v_receiver *receiver;struct x2v_hook_clip *hook;unsigned generation;int trigger_seen,output_fd,ack_fd;};
extern void x2v_color_report(unsigned);
static struct clip_control clips[2];
static int command_fd=-1;
static uint64_t constructor_deadline;
static int control_fds(void){
 /* FD5/6 remain readonly native SP/conf parser inputs. Child ACK2 owns9;
  * the launcher's recovery-lock FD9 must never be inherited as this sink. */
 const int fd[5]={7,3,4,8,9};struct stat st[5];
 for(unsigned i=0;i<5;i++){
  int fl=fcntl(fd[i],F_GETFL);
  if(fl<0||fstat(fd[i],&st[i]))return EINVAL;
  if(i==1||i==2){if(!S_ISDIR(st[i].st_mode)||(fl&O_ACCMODE)!=O_RDONLY||(fl&(O_APPEND|O_DIRECT|O_DSYNC|O_SYNC)))return EINVAL;}
  else if(!S_ISREG(st[i].st_mode)||st[i].st_nlink!=1)return EINVAL;
  if(i==0){if(st[i].st_size!=1||(fl&O_ACCMODE)!=O_RDONLY)return EINVAL;}
  else if(i>=3&&(st[i].st_size||(fl&O_ACCMODE)!=O_RDWR||(fl&(O_APPEND|O_DIRECT|O_DSYNC|O_SYNC))||lseek(fd[i],0,SEEK_CUR)!=0))return EINVAL;
  for(unsigned j=0;j<i;j++)if(st[i].st_dev==st[j].st_dev&&st[i].st_ino==st[j].st_ino)return EINVAL;
 }
 char b;if(pread(7,&b,1,0)!=1||b!='0')return EINVAL;
 int own[5]={-1,-1,-1,-1,-1};
 for(unsigned i=0;i<5;i++)if((own[i]=fcntl(fd[i],F_DUPFD_CLOEXEC,10))<0){for(unsigned j=0;j<i;j++)close(own[j]);return EINVAL;}
 command_fd=own[0];clips[0].output_fd=own[1];clips[1].output_fd=own[2];clips[0].ack_fd=own[3];clips[1].ack_fd=own[4];return 0;
}
static int ack(struct clip_control *c,int rc,int expired,int drain_attempted,int drain_rc){
 struct x2v_receiver *ctx=c->receiver;struct x2v_hook_clip *h=c->hook;
 uint32_t id=0;uint64_t stamp=0;int error=0,s=x2v_receiver_status(ctx,&error,&id,&stamp);
 /* Exactly one control consumer per loaded receiver. Constructor failure
  * calls finish only when no consumer thread was created. Keep the receipt
  * workspace out of the thread stack (about 660 KiB at the 240-frame cap). */
 static char fields[3072],sequence[393216],provider[768],writer_provider[768],out[409600];if(!x2v_hook_json(h,fields,sizeof fields)||!x2v_receiver_sequence_json(ctx,sequence,sizeof sequence)||!x2v_copy_provider_json(provider,sizeof provider)||!x2v_writer_provider_json(writer_provider,sizeof writer_provider))return EOVERFLOW;
 int n=snprintf(out,sizeof out,"{\"scope\":\"receiver_cpu_drain\",\"version\":16,\"clip_generation\":%u,\"rc\":%d,\"state\":%d,\"error\":%d,\"drain_attempted\":%d,\"drain_rc\":%d,\"cpu_drained\":%d,\"no_arm\":%d,\"trigger_seen\":%d,\"capture_armed\":%d,\"frame_id\":%u,\"timestamp_native\":%llu,\"callback_active\":%d,\"expired\":%d,\"expected_bytes\":%llu,%s,%s,%s,%s}\n",c->generation,rc,s,error,drain_attempted,drain_rc,x2v_receiver_cpu_drained(ctx),!x2v_receiver_capture_armed(ctx),c->trigger_seen,x2v_receiver_capture_armed(ctx),id,(unsigned long long)stamp,x2v_receiver_callback_active(h),expired||x2v_receiver_expired(ctx),(unsigned long long)X2V_MAX_FRAMES*X2V_DNG_FILE_BYTES,sequence,provider,writer_provider,fields);
 if(n<=0||(size_t)n>=sizeof out)return EOVERFLOW;
 size_t pos=0;while(pos<(size_t)n){ssize_t w=write(c->ack_fd,out+pos,(size_t)n-pos);if(w<0&&errno==EINTR)continue;if(w<=0)return w<0?errno:EIO;pos+=(size_t)w;}return fsync(c->ack_fd)?errno:0;
}

#ifndef X2V_BEFORE_FINAL_COMMAND
#define X2V_BEFORE_FINAL_COMMAND(c) ((void)0)
#endif
static int allowed_command(struct clip_control*c,char b){
 return b=='0'||b=='A'||b=='S'||b=='D'||(c->generation==2&&(b=='B'||b=='T'));
}
static int finish(struct clip_control*c,int rc,int expired){
 struct x2v_receiver*ctx=c->receiver;struct x2v_hook_clip*h=c->hook;
 x2v_hook_close(h);x2v_receiver_disarm(ctx);
 unsigned i=0;int attempted=0,drain_rc=EAGAIN;
 for(;i<10000&&x2v_receiver_callback_active(h);i++)usleep(1000);
 if(x2v_receiver_callback_active(h))rc=ETIMEDOUT;
 else{attempted=1;drain_rc=x2v_receiver_drain(ctx,10000);if(!rc)rc=drain_rc;}
 if(!rc){int e=0;x2v_receiver_status(ctx,&e,NULL,NULL);rc=e;}
 if(!rc)rc=x2v_receiver_sequence_error(ctx);
 if(!rc)rc=x2v_receiver_vendor_error(h);
 x2v_receiver_poll(ctx);
 if(c->output_fd>=0){if(close(c->output_fd)&&!rc)rc=errno;c->output_fd=-1;}
 X2V_BEFORE_FINAL_COMMAND(c);
 char final_command;
 if(command_fd<0||pread(command_fd,&final_command,1,0)!=1){if(!rc)rc=EIO;}
 else if(final_command=='D'){x2v_receiver_abort(ctx);if(!rc)rc=ECANCELED;}
 else if(!allowed_command(c,final_command)){if(!rc)rc=EINVAL;}
 x2v_color_report(c->generation);
 int published=ack(c,rc,expired,attempted,drain_rc);
 if(c->ack_fd>=0){if(close(c->ack_fd)&&!published)published=errno;c->ack_fd=-1;}
 return published?published:rc;
}
static int command(struct clip_control*c,char b){
 if(!allowed_command(c,b))return EINVAL;
 if(b=='D'){x2v_receiver_abort(c->receiver);return ECANCELED;}
 /* Stale generation1 commands cannot arm or stop generation2. */
 if(c->generation==2&&(b=='A'||b=='S'))return 0;
 if(b==(c->generation==1?'A':'B')){
  if(c->trigger_seen)return 0;
  /* Camera linker lazily loads base.so. Bind only after graph setup, before
   * admission publication; never load/lookup from the borrowed callback.
   * Missing diagnostics do not reject otherwise valid RAW frames. */
  if(c->generation==1){int mr=xmd_bind_getter();fprintf(stderr,"XMD_BIND arm_metadata_rc=%d best_effort=1\n",mr);}
  c->trigger_seen=1;return x2v_receiver_activate(c->receiver);
 }
 if(b==(c->generation==1?'S':'T'))return x2v_receiver_stop(c->receiver);
 return 0;
}
static int run_clip(struct clip_control*c){
 int rc=0,expired=0;
 for(;;){
  uint64_t now=x2v_receiver_millis();char b;
  if(!now||pread(command_fd,&b,1,0)!=1){rc=EIO;break;}
  x2v_receiver_poll(c->receiver);int s=x2v_receiver_status(c->receiver,NULL,NULL,NULL);
  if(!constructor_deadline||now>=constructor_deadline)expired=1;
  if(b=='D'){rc=command(c,b);break;}
  if(expired)break;
  if(s==X2V_RX_DONE||s==X2V_RX_ERROR||s==X2V_RX_CANCELLED||x2v_receiver_vendor_error(c->hook))break;
  rc=command(c,b);if(rc)break;
  usleep(20000);
 }
 return finish(c,rc,expired);
}
static void*controller(void*unused){
 (void)unused;int rc=run_clip(&clips[0]);
#ifdef X2V_BETWEEN_CLIPS
 X2V_BETWEEN_CLIPS();
#endif
 if(!rc&&x2v_receiver_capture_success(clips[0].receiver)&&x2v_receiver_cpu_drained(clips[0].receiver)){
  /* Source and provider bindings remain alive. Only clip-local CPU/FD state is new. */
  char b;
  if(pread(command_fd,&b,1,0)!=1)rc=EIO;
  else if(b=='D')rc=ECANCELED;
  if(!rc)rc=x2v_receiver_prepare_normal(clips[1].receiver,clips[1].output_fd);
  if(!rc)rc=x2v_hook_open(clips[1].hook);
  if(!rc)rc=run_clip(&clips[1]);
  else (void)finish(&clips[1],rc,0);
 }else (void)finish(&clips[1],rc?rc:ECANCELED,0);
 if(command_fd>=0)close(command_fd);command_fd=-1;
 return NULL;
}
#ifndef X2V_HOST_TEST
__attribute__((constructor)) static void setup(void){
 uint64_t begin=x2v_receiver_millis();constructor_deadline=begin?begin+47000:0;
 int binding=x2v_hook_bind();const char*t=getenv("X2V_RECEIVER_ONESHOT");if(!t||strcmp(t,X2V_TOKEN))return;
 for(unsigned i=0;i<2;i++){
  clips[i].output_fd=clips[i].ack_fd=-1;clips[i].generation=i+1;
  clips[i].receiver=x2v_receiver_new(i+1,constructor_deadline);
  clips[i].hook=x2v_hook_clip_new(clips[i].receiver,i+1);
  if(!clips[i].receiver||!clips[i].hook)return;
 }
 int e=control_fds();if(e){fprintf(stderr,"X2V_RX16 FD contract error=%d\n",e);return;}
 int copy_binding=x2v_copy_provider_bind();int writer_binding=copy_binding?0:x2v_writer_provider_bind();
 e=binding?binding:copy_binding?copy_binding:writer_binding?writer_binding:!begin?EIO:0;
 if(!e)e=x2v_receiver_prepare_normal(clips[0].receiver,clips[0].output_fd);
 if(!e)e=x2v_hook_open(clips[0].hook);
 if(!e){pthread_t thread;e=pthread_create(&thread,NULL,controller,NULL);if(!e)pthread_detach(thread);}
 if(e){(void)finish(&clips[0],e,0);(void)finish(&clips[1],e,0);if(command_fd>=0)close(command_fd);command_fd=-1;}
}
#endif
