#include "target_topology.h"
#include <stddef.h>
#include <stdint.h>
#include <string.h>
#include <errno.h>
extern int x2v_isp_full_transfer_geometry(void *,size_t);
static uint32_t r32(const void *p,size_t o){uint32_t v;memcpy(&v,(const char*)p+o,4);return v;}
static uintptr_t rp(const void *p,size_t o){uintptr_t v;memcpy(&v,(const char*)p+o,8);return v;}
static void w32(void *p,size_t o,uint32_t v){memcpy((char*)p+o,&v,4);}
static void w16(void *p,size_t o,uint16_t v){memcpy((char*)p+o,&v,2);}
int x2v_target_topology_clone(struct x2v_target_topology *out,const void *cam_info,int mode21){
 if(!out||!cam_info)return EINVAL;
 const void *header=(void*)rp(cam_info,0x130);
 if(!header||r32(header,0)!=7)return EPROTO;
 const unsigned char *rows=(void*)rp(header,8);if(!rows)return EPROTO;
 const unsigned char *src=rows+0x640;
 if(r32(src,0x100)!=7408||r32(src,0x104)!=1482||r32(src,0x148)!=7408||
    r32(src,0x14c)!=1482||r32(src,0x120)!=96||r32(src,0x154)!=96||r32(src,0xa8)!=2||rp(src,0x10))return EPROTO;
 const unsigned char *ports=(void*)rp(src,0xf0);if(!ports)return EPROTO;
 for(unsigned i=0;i<40;i++){
  uint16_t wh[2];memcpy(wh,ports+i*0x50+0x42,4);
  if(i==0||i==10){if(wh[0]!=3920||wh[1]!=1264)return EPROTO;}
  else if(wh[0]||wh[1])return EPROTO;
 }
  /* DRAFT REVIEW ONLY. Original row1 retains RAW BOUT 3920x986 with
   * crop y496 even when allocation/source receiver becomes2946. Validate
   * every field before replacing only the owned target row. */
 if(mode21 && (r32(src,0x1c0)!=3920||r32(src,0x1c4)!=986||
     r32(src,0x1d0)!=3920||r32(src,0x1d4)!=986||r32(src,0x1ec)!=1||
     r32(src,0x1f0)!=0||r32(src,0x1f4)!=496||
     r32(src,0x1f8)!=3920||r32(src,0x1fc)!=986||
     r32(src,0x200)!=0||r32(src,0x204)!=0))return EPROTO;
 memcpy(out->rows,rows,sizeof out->rows);memcpy(out->ports,ports,sizeof out->ports);
 out->header.count=7;out->header.pad=0;out->header.rows=(uintptr_t)out->rows;
 unsigned char *row=out->rows+0x640;uintptr_t p=(uintptr_t)out->ports;memcpy(row+0xf0,&p,8);
 if(mode21){
  w32(row,0x100,3920);w32(row,0x104,2946);w32(row,0x148,3920);w32(row,0x14c,2946);
  w32(row,0x1c0,3920);w32(row,0x1c4,2946);
  w32(row,0x1d0,3920);w32(row,0x1d4,2946);
  /* Keep crop enabled; request exact full transport, not guessed optical ROI. */
  w32(row,0x1f0,0);w32(row,0x1f4,0);w32(row,0x1f8,3920);w32(row,0x1fc,2946);
  /* Owned SUB geometry only; coefficients and native dual graph remain unverified. */
  int isp_rc=x2v_isp_full_transfer_geometry(row,0x640);
  if(isp_rc)return isp_rc;
  for(unsigned i=0;i<40;i++)if(i==0||i==10){w16(out->ports+i*0x50,0x42,3920);w16(out->ports+i*0x50,0x44,2946);}
 }
 /* row0 entirely native, normal startup never consumes target receiver. */
 return 0;
}
int x2v_target_active_rect(const struct x2v_target_topology *out,int profile,void *rect10){
 if(!out||!rect10||profile!=2)return EINVAL;
 /* Same native get_active_size 4fd0–4fe0: first10 bytes at port+3c.
  * No guessed crop origin. This is full transport request, not optical crop. */
 memcpy(rect10,out->ports+0x3c,10);return 0;
}
