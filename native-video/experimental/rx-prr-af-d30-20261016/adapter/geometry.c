/* Applies only to a caller-owned RX16/RX17 mode21 row1 clone.
 * No native pointers, driver calls, register writes or executable preload. */
#include <stddef.h>
#include <stdint.h>
#include <string.h>
#include <errno.h>
#include "native_sub_pin.h"
static uint32_t read32(const unsigned char *p, size_t o) {
 uint32_t v; memcpy(&v,p+o,4); return v;
}
static void write32(unsigned char *p,size_t o,uint32_t v) {
 memcpy(p+o,&v,4);
}
int x2v_isp_full_transfer_geometry(void *owned_row,size_t size) {
 if(!owned_row||size!=0x640)return EINVAL;
 unsigned char *r=owned_row;
 /* This module must follow the unchanged RAW clone, never patch a stock row. */
 const size_t widths[]={0x100,0x148,0x1c0,0x1d0,0x1f8};
 const size_t heights[]={0x104,0x14c,0x1c4,0x1d4,0x1fc};
 for(size_t i=0;i<5;i++)
  if(read32(r,widths[i])!=3920||read32(r,heights[i])!=2946)return EPROTO;
 if(read32(r,0x1ec)!=1||read32(r,0x1f0)||read32(r,0x1f4))return EPROTO;
 /* Whole native SUB block, including enables, slots, formats and padding.
  * A second application or unknown firmware fails before changing any byte. */
 if(memcmp(r+0x5ac,native_sub_pin,sizeof native_sub_pin))return EPROTO;
 write32(r,0x5bc,2946);
 write32(r,0x5cc,0);write32(r,0x5d0,0);
 write32(r,0x5dc,3920);write32(r,0x5e0,2946);
 return 0;
}
