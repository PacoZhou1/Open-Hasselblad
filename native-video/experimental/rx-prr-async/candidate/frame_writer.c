#define _POSIX_C_SOURCE 200809L
#include "frame_writer.h"
#include <errno.h>
#include <fcntl.h>
#include <string.h>
#include <sys/stat.h>
#include <time.h>
#include <unistd.h>
struct tag { uint16_t id,type; uint32_t count,size; unsigned char bytes[128]; };
struct tags { struct tag t[40]; unsigned n; };
_Static_assert(sizeof(struct dng_rational)==8,"rational layout");
_Static_assert(sizeof(struct dng_srational)==8,"signed rational layout");
static void p16(unsigned char*p,uint16_t v){p[0]=(unsigned char)v;p[1]=(unsigned char)(v>>8);}
static void p32(unsigned char*p,uint32_t v){p[0]=(unsigned char)v;p[1]=(unsigned char)(v>>8);p[2]=(unsigned char)(v>>16);p[3]=(unsigned char)(v>>24);}
static int fail(int e){errno=e;return -1;}
static void bytes(struct tags*d,uint16_t id,uint16_t type,uint32_t count,const void*p,uint32_t n){struct tag*t=&d->t[d->n++];t->id=id;t->type=type;t->count=count;t->size=n;memcpy(t->bytes,p,n);}
static void scalar(struct tags*d,uint16_t id,uint16_t type,uint32_t value){unsigned char b[4]={0};if(type==3)p16(b,(uint16_t)value);else p32(b,value);bytes(d,id,type,1,b,type==3?2:4);}
static void rat(struct tags*d,uint16_t id,uint16_t type,const void*input,unsigned n){
 unsigned char b[72];const unsigned char*s=input;
 for(unsigned i=0;i<n;i++){uint32_t num,den;memcpy(&num,s+8*i,4);memcpy(&den,s+8*i+4,4);p32(b+8*i,num);p32(b+8*i+4,den);}
 bytes(d,id,type,n,b,8*n);
}
int x2v_dng_header(const struct dng_bayer_frame*f,const struct dng_frame_profile*p,
 unsigned char header[4096],uint64_t *pixel_out){

 if(!f||!p||!header||!pixel_out||!f->data||!p->unique_camera_model||!f->width||!f->height||
    (f->width|f->height)&1u||f->width>11904||f->height>8842||
    (f->output_bits!=12&&f->output_bits!=16))return fail(EINVAL);
 size_t row=(size_t)f->width*2;
 if(f->stride<row||f->stride>65536||
    (size_t)(f->height-1)>SIZE_MAX/f->stride||
    (size_t)(f->height-1)*f->stride>f->span||row>f->span-(size_t)(f->height-1)*f->stride)return fail(EINVAL);
 size_t model_len=strnlen(p->unique_camera_model,127);
 if(!model_len||model_len>=127||!p->black_level.denominator||
    !p->white_level||p->white_level>((1u<<f->output_bits)-1u)||
    (uint64_t)p->black_level.numerator>=(uint64_t)p->white_level*p->black_level.denominator)return fail(EINVAL);
 unsigned count[3]={0};for(unsigned i=0;i<4;i++){if(p->cfa[i]>2)return fail(EINVAL);count[p->cfa[i]]++;}
 if(count[0]!=1||count[1]!=2||count[2]!=1)return fail(EINVAL);
 for(unsigned i=0;i<9;i++)if(p->color_matrix1[i].denominator<=0)return fail(EINVAL);
 for(unsigned i=0;i<3;i++)if(!p->as_shot_neutral[i].denominator||!p->as_shot_neutral[i].numerator)return fail(EINVAL);
 size_t packedrow=f->output_bits==16?row:(size_t)f->width*3/2;
 uint64_t pixel_bytes=(uint64_t)packedrow*f->height;
 if(pixel_bytes+4096>256u*1024u*1024u)return fail(EFBIG);
 struct tags d={0};const unsigned char version[4]={1,4,0,0},back[4]={1,1,0,0},repeat[4]={2,0,2,0},colors[3]={0,1,2};
 scalar(&d,254,4,0);scalar(&d,256,4,f->width);scalar(&d,257,4,f->height);
 scalar(&d,258,3,f->output_bits);scalar(&d,259,3,1);scalar(&d,262,3,32803);
 scalar(&d,266,3,1);
 const char warning[]="UNCALIBRATED: explicit assumed CFA/profile; preserved RAW16_OPAQUE words; no verified optical active crop";
 bytes(&d,270,2,sizeof warning,warning,sizeof warning);
 scalar(&d,273,4,4096);scalar(&d,274,3,1);scalar(&d,277,3,1);
 scalar(&d,278,4,f->height);scalar(&d,279,4,(uint32_t)pixel_bytes);scalar(&d,284,3,1);
 const char software[]="X2V PROVISIONAL CPU DNG sequence";
 bytes(&d,305,2,sizeof software,software,sizeof software);
 bytes(&d,33421,3,2,repeat,4);bytes(&d,33422,1,4,p->cfa,4);
 bytes(&d,50706,1,4,version,4);bytes(&d,50707,1,4,back,4);
 bytes(&d,50708,2,(uint32_t)model_len+1,p->unique_camera_model,(uint32_t)model_len+1);
 bytes(&d,50710,1,3,colors,3);scalar(&d,50711,3,1);
 bytes(&d,50713,3,2,(unsigned char[]){1,0,1,0},4);
 rat(&d,50714,5,&p->black_level,1);scalar(&d,50717,4,p->white_level);
 struct dng_rational croporigin[2]={{0,1},{0,1}},cropsize[2]={{f->width,1},{f->height,1}};
 rat(&d,50719,5,croporigin,2);rat(&d,50720,5,cropsize,2);
 rat(&d,50721,10,p->color_matrix1,9);rat(&d,50728,5,p->as_shot_neutral,3);
 scalar(&d,50778,3,p->calibration_illuminant1);
 unsigned char active[16]={0};p32(active+8,f->height);p32(active+12,f->width);bytes(&d,50829,4,4,active,16);
 /*Ascending by construction. Header offset fixed4096 for future aligned I/O.*/
 memset(header,0,4096);memcpy(header,"II\052\0",4);p32(header+4,8);p16(header+8,(uint16_t)d.n);
 uint32_t extra=8+2+12*d.n+4;
 for(unsigned i=0;i<d.n;i++){struct tag*t=&d.t[i];unsigned char*e=header+10+12*i;
  if(i&&d.t[i-1].id>=t->id)return fail(EINVAL);
  p16(e,t->id);p16(e+2,t->type);p32(e+4,t->count);
  if(t->size<=4)memcpy(e+8,t->bytes,t->size);else{if(extra+t->size>4096)return fail(EOVERFLOW);p32(e+8,extra);memcpy(header+extra,t->bytes,t->size);extra+=(t->size+1)&~1u;}}
 *pixel_out=pixel_bytes;return 0;
}
