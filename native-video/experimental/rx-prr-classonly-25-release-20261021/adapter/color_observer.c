/* Bounded metadata only. No HAL lease, map, pixels, allocation or IO on callback. */
#include <stdint.h>
#include <stdatomic.h>
#include <string.h>
#include <stdio.h>
static _Atomic unsigned seen,ready;
static uint32_t first[8];
static int eq(const char*a,const char*b){if(!a)return 0;while(*b){if(*a++!=*b++)return 0;}return !*a;}
void x2v_color_observe(const char *name,const char *port,const void *frame){
 if(!frame||!eq(name,"color_null")||!eq(port,"FlterDmp"))return;
 if(atomic_fetch_add_explicit(&seen,1,memory_order_relaxed))return;
 const unsigned offsets[]={0x28,0x2c,0x38,0x3c,0x40,0x44,0x4c,0xb0};
 for(unsigned i=0;i<8;i++)memcpy(&first[i],(const char*)frame+offsets[i],4);
 atomic_store_explicit(&ready,1,memory_order_release);
}
/* Worker thread after RAW drain; not part of authoritative RAW receipt. */
void x2v_color_report(unsigned generation){
 unsigned n=atomic_load_explicit(&seen,memory_order_relaxed);
 if(!atomic_load_explicit(&ready,memory_order_acquire)){
  fprintf(stderr,"X2V_ISP_COLOR generation=%u observed=0\n",generation);return;
 }
 fprintf(stderr,"X2V_ISP_COLOR generation=%u observed=%u pixel=%u aux=%u width=%u height=%u stride=%u offset=%u planeheight=%u planes=%u\n",generation,n,first[0],first[1],first[2],first[3],first[4],first[5],first[6],first[7]);
}
