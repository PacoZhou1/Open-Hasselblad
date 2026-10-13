#include "metadata_record.h"
#include <errno.h>
#include <string.h>

static const uint32_t tags[XMD_FIELD_COUNT]={0x3ea,0x3eb,0x3ee,0x3ef,0x41c,0x41d,0x41e,0x41f,0x423,0x4c3,0x50c,0x5a6,0x5bb};
static int shape(const struct xmd_snapshot *s){
    if(!s||s->state>XMD_NOT_READ_ONLY||s->exact_exposure_frame_match_proven)return EPROTO;
    for(unsigned i=0;i<XMD_FIELD_COUNT;i++)
        if(s->fields[i].tag!=tags[i]||s->fields[i].state>XMD_NULL_DATA||
           s->fields[i].copied_bytes>XMD_DATA_BYTES||
           (s->fields[i].state!=XMD_COPIED&&s->fields[i].copied_bytes))return EPROTO;
    return 0;
}
int xmd_record_store(struct xmd_record *r,uint64_t clip,uint64_t slot,uint32_t index,
    uint32_t id,uint64_t stamp,const struct xmd_snapshot *s){
    if(!r||!clip||!slot||index>=240||!id||!stamp||!s)return EINVAL;
    if(r->ready)return EALREADY;
    if(shape(s)||s->frame_id!=id||s->native_timestamp!=stamp)return EPROTO;
    r->clip_generation=clip;r->slot_generation=slot;r->frame_index=index;
    memcpy(&r->snapshot,s,sizeof *s);r->ready=1;
    return 0;
}
int xmd_record_matches(const struct xmd_record *r,uint64_t clip,uint64_t slot,
    uint32_t index,uint32_t id,uint64_t stamp){
    if(!r||r->ready!=1||!clip||!slot||index>=240||!id||!stamp)return EINVAL;
    return shape(&r->snapshot)||r->clip_generation!=clip||r->slot_generation!=slot||
        r->frame_index!=index||r->snapshot.frame_id!=id||r->snapshot.native_timestamp!=stamp?EPROTO:0;
}
static void byte_hex(char *out,size_t *p,uint8_t value){
    static const char digits[]="0123456789abcdef";
    out[(*p)++]=digits[value>>4];out[(*p)++]=digits[value&15];
}
static void little_hex(char *out,size_t *p,uint64_t value,unsigned width){
    for(unsigned i=0;i<width;i++)byte_hex(out,p,(uint8_t)(value>>(i*8)));
}
int xmd_record_hex(const struct xmd_record *r,char *out,size_t cap){
    if(!r||!out||cap<XMD_HEX_BYTES+1||r->ready!=1||shape(&r->snapshot))return EINVAL;
    const struct xmd_snapshot *s=&r->snapshot;size_t p=0;
    little_hex(out,&p,0x31444d58u,4); /* XMD1 */
    little_hex(out,&p,1,2);little_hex(out,&p,XMD_FIELD_COUNT,2);
    little_hex(out,&p,XMD_WIRE_BYTES,4);little_hex(out,&p,0,4);
    little_hex(out,&p,r->clip_generation,8);little_hex(out,&p,r->slot_generation,8);
    little_hex(out,&p,r->frame_index,4);little_hex(out,&p,s->frame_id,4);
    little_hex(out,&p,s->native_timestamp,8);little_hex(out,&p,s->state,4);
    little_hex(out,&p,s->container_permission,4);little_hex(out,&p,s->observed_writer_count,2);
    little_hex(out,&p,s->exact_exposure_frame_match_proven,1);little_hex(out,&p,0,1);
    for(unsigned i=0;i<XMD_FIELD_COUNT;i++){
        const struct xmd_field *f=&s->fields[i];
        little_hex(out,&p,f->tag,4);little_hex(out,&p,f->state,4);
        little_hex(out,&p,(uint32_t)f->native_type,4);little_hex(out,&p,(uint32_t)f->native_count,4);
        little_hex(out,&p,f->copied_bytes,4);
        for(unsigned j=0;j<XMD_DATA_BYTES;j++)byte_hex(out,&p,f->data[j]);
    }
    if(p!=XMD_HEX_BYTES)return EPROTO;out[p]=0;return 0;
}
