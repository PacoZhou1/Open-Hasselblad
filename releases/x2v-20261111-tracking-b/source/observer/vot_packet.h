#ifndef X2V_VOT_PACKET_H
#define X2V_VOT_PACKET_H
#include <stdint.h>
#include <stddef.h>
#include <string.h>
#include <math.h>
/* Firmware 1.3.16.2 Worker::onResult / parseBox. NOT an AF-map decoder. */
#define VOT_MAX_PACKET (0x48u + 255u * 0x34u)
static uint16_t vot_u16(const unsigned char *p) { uint16_t v; memcpy(&v,p,2); return v; }
static uint32_t vot_u32(const unsigned char *p) { uint32_t v; memcpy(&v,p,4); return v; }
static float vot_f32(const unsigned char *p) { float v; memcpy(&v,p,4); return v; }
static int vot_seed_request(const unsigned char *p,size_t n) { return p&&n==40&&p[9]==1&&p[12]==2&&p[16]==9; }
static int vot_seed_ack(const unsigned char *p,size_t n,unsigned tag) { return p&&n>=16&&tag==(unsigned)p[8]+1&&p[9]==21&&!vot_u32(p+12); }
typedef struct {
 uint32_t frame_id; unsigned width,height,kind,count,selected_valid;
 int32_t selected_id; unsigned status,record_type; int selected_found,available,arbitrary,tracked,lost;
 double x,y,w,h,confidence;
} VotResult;
static int vot_packet(const unsigned char *p,size_t n,VotResult *out) {
 if (!p || !out || n<0x48 || n>VOT_MAX_PACKET) return 0;
 unsigned count=p[0x44];
 if ((size_t)count>(n-0x48)/0x34) return 0;
 memset(out,0,sizeof *out);
 out->frame_id=vot_u32(p+0x10); out->width=vot_u16(p+0x14); out->height=vot_u16(p+0x16);
 out->kind=p[0x1c];out->count=count;out->selected_valid=p[0x1f];
 out->selected_id=out->selected_valid?(int32_t)vot_u32(p+0x20):-1;
 if (!out->width || !out->height || (out->kind!=2 && out->kind!=9)) return 0;
 if (out->kind!=9) return 1;
 if (!out->selected_valid) { out->lost=1;return 1; }
 for (unsigned i=0;i<count;i++) {
  const unsigned char *b=p+0x48+i*0x34;
  if ((int32_t)vot_u32(b)!=out->selected_id) continue;
  out->selected_found=1;out->record_type=b[4];out->status=b[6];
  // Native onResult jump tables map raw0 -> E_Landmark_Arbitrary(14).
  // Raw1 -> landmark8 and raw30 -> landmark13; neither is arbitrary.
  out->arbitrary=out->record_type==0;
  out->available=out->status>=1 && out->status<=3;
  out->w=vot_f32(b+16);out->h=vot_f32(b+20);
  out->x=(double)vot_f32(b+8)-out->w/2;out->y=(double)vot_f32(b+12)-out->h/2;
  out->confidence=vot_f32(b+24);
  out->lost=out->status==0 || out->status==255;
  // Native onResult uses (status-1)<3 for MlData.available. No invented threshold.
  out->tracked=out->arbitrary && out->available && isfinite(out->x) && isfinite(out->y) &&
   isfinite(out->w) && isfinite(out->h) && isfinite(out->confidence) && out->x>=0 && out->y>=0 &&
   out->w>0 && out->h>0 && out->x+out->w<=1.000001 && out->y+out->h<=1.000001;
  return 1;
 }
 // Selected id has no record: no native target can be shown as available.
 out->lost=1;
 return 1;
}
#endif
