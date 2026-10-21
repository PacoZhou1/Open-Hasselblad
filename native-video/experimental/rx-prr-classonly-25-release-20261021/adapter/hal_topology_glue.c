#define _GNU_SOURCE 1
#include "target_topology.h"
#include "hal_profile_adapter.h"
#include "target_descriptor.h"
#include <stdint.h>
#include <string.h>
#include <errno.h>
#include <dlfcn.h>
#include <stdio.h>
#ifndef X2V_ENABLE_MODE21_PROFILE
#define X2V_ENABLE_MODE21_PROFILE 0
#endif
/* One camera owner. Native caller constructs camera once on owner thread.
 * Retain the deep copies for process lifetime, never dlclose while owner live.
 * Startup profile1/HB23 remains completely native. */
static struct x2v_target_topology topology;
static X2vOwnedHalProfiles profiles;
static int ready;
static int (*native_active)(int,void *);
static int bitdepth(int profile,uint16_t *out){return x2v_hal_bitdepth(&profiles,profile,out);}
static int aux58(int profile,uint32_t *out){return x2v_hal_aux58(&profiles,profile,out);}
static int mode_name(int p,unsigned bytes,int *id,char *name){return x2v_hal_mode_name(&profiles,p,bytes,id,name);}
static int active_rect(int profile,void *rect){
 if(profile==2)return x2v_target_active_rect(&topology,profile,rect)?-1003:0;
 return native_active?native_active(profile,rect):-1003;
}
static void slot(void *info,size_t offset,const void *fn){memcpy((char*)info+offset,&fn,8);}
int x2v_apply_owned_cam_info(void *cam_info,const char *stage){
 if(!cam_info||!stage)return EINVAL;
 int target=!strcmp(stage,"mode21-c25");
 if(strcmp(stage,"normal") && !(target&&X2V_ENABLE_MODE21_PROFILE))return ENOTSUP;
 if(!ready){
  uintptr_t native_header;memcpy(&native_header,(char*)cam_info+0x120,8);
  if(!native_header)return EPROTO;
  /* Header base binding checked by x2v_clone_hal_profiles; unlike guessed
   * dlsym addresses, subtracts pinned actual second-level header VA289b0. */
  uintptr_t hal_bias=native_header-0x289b0;
  int e=x2v_clone_hal_profiles(&profiles,cam_info,hal_bias);if(e)return EPROTO;
  e=x2v_target_topology_clone(&topology,cam_info,target);if(e)return e;
  if(target && x2v_bind_mode21_c24(&profiles))return EPROTO;
  memcpy(&native_active,(char*)cam_info+0x1500,8);ready=1;
 }
 uintptr_t h=(uintptr_t)&profiles.header;memcpy((char*)cam_info+0x120,&h,8);
 h=(uintptr_t)&topology.header;memcpy((char*)cam_info+0x130,&h,8);
 slot(cam_info,0x14e0,(const void*)bitdepth);slot(cam_info,0x14e8,(const void*)aux58);
 slot(cam_info,0x1540,(const void*)mode_name);slot(cam_info,0x1500,(const void*)active_rect);
 /* 1510 topology index,1538 topology/segment names unchanged forprofile2→1.
  * Mapping2618/3238 returns index by original string, not raw descriptorptr;
  * framework obtains receiver descriptors from the replaced array header. */
 fprintf(stderr,"X2V_GRAPH owned HAL headers installed stage=%s profile2_target=%d\n",stage,target);
 return 0;
}
