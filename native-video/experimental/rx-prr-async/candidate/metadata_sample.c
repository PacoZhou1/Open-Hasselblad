#include "metadata_sample.h"
#include <string.h>

_Static_assert(sizeof(void *)==8, "only recovered64bit ABI");
_Static_assert(offsetof(struct xmd_native_value,type)==0, "native value type");
_Static_assert(offsetof(struct xmd_native_value,count)==4, "native value count");
_Static_assert(offsetof(struct xmd_native_value,data)==8, "native value data");

struct field_rule { uint32_t tag; int32_t type, min_count, max_count; uint32_t width, prefix_bytes; };
static const struct field_rule rules[XMD_FIELD_COUNT]={
    {0x3ea,6,1,1,4,0}, /* VIDEO_SHUTTER_TIME: raw FLOAT seconds */
    {0x3eb,6,1,1,4,0}, /* STILL_SHUTTER_TIME: raw FLOAT seconds */
    {0x3ee,4,1,1,4,0}, /* VIDEO_ISO: UINT32 */
    {0x3ef,4,1,1,4,0}, /* STILL_ISO: UINT32 */
    {0x41c,5,1,1,4,0}, /* STILL_SENSOR_ANALOG_GAIN: INT32; native /1000 */
    {0x41d,5,1,1,4,0}, /* VIDEO_SENSOR_ANALOG_GAIN: preserve raw INT32 */
    {0x41e,5,1,1,4,0}, /* STILL_SENSOR_DIGITAL_GAIN: preserve raw INT32 */
    {0x41f,5,1,1,4,0}, /* VIDEO_SENSOR_DIGITAL_GAIN: preserve raw INT32 */
    {0x423,5,1,1,4,0}, /* STILL_ISP_DIGITAL_GAIN: preserve raw INT32 */
    {0x4c3,5,1,4,4,0}, /* BLACK_LEVEL_DNG: native INT32 array, not measured OB */
    {0x50c,2,1,1,2,0}, /* BIT_DEPTH: native UINT16 status; no photo14/16 assertion */
    {0x5a6,4,1,1,4,0}, /* SENSOR_SHUTTER_MODE/reset: native UINT32 enum */
    {0x5bb,1,4,4096,1,4}, /* SENSOR_MODE: only the native consumed4byte prefix */
};

static uint32_t read32(const void *p,size_t offset){uint32_t v;memcpy(&v,(const unsigned char*)p+offset,4);return v;}
static uint64_t read64(const void *p,size_t offset){uint64_t v;memcpy(&v,(const unsigned char*)p+offset,8);return v;}

int xmd_sample_borrowed_frame(const void *frame,size_t known_native_frame_bytes,
    int verified_native_contract,xmd_get_by_id_fn get_by_id,struct xmd_snapshot *out){
    if(!out)return XMD_BAD_CONTRACT;
    memset(out,0,sizeof *out);
    out->state=XMD_BAD_CONTRACT;
    for(unsigned i=0;i<XMD_FIELD_COUNT;i++)out->fields[i].tag=rules[i].tag;
    if(!frame||known_native_frame_bytes<0x340)return out->state;
    out->frame_id=read32(frame,0xb4);
    out->native_timestamp=read64(frame,0x30);
    if(verified_native_contract!=1||!get_by_id)return out->state;
    void *container=NULL;
    /* frame+338 is proven by native init/free/shallow-copy and CalEng readers. */
    memcpy(&container,(const unsigned char*)frame+0x338,sizeof container);
    if(!container){out->state=XMD_NO_CONTAINER;return out->state;}
    /* Native get_by_id asserts on concurrent writer or absent READ permission.
     * These offsets/bit are recovered from that exact native implementation.
     * They are skip guards, not a lock. The frame callback lease remains required. */
    memcpy(&out->observed_writer_count,(const unsigned char*)container+0x28,2);
    out->container_permission=read32(container,0x44);
    if(out->observed_writer_count){out->state=XMD_ACTIVE_WRITER;return out->state;}
    if(!(out->container_permission&1u)){out->state=XMD_NO_READ_PERMISSION;return out->state;}
    /* Native READ permission is a capability mask, and alloc defaults to3.
     * Accept only the two recovered READ-capable enums1/3. The synchronous
     * borrowed frame before original forward remains the lifetime boundary;
     * writer_count is a skip guard, never advertised as a blocking read lock. */
    if(out->container_permission!=1u&&out->container_permission!=3u){out->state=XMD_NOT_READ_ONLY;return out->state;}
    for(unsigned i=0;i<XMD_FIELD_COUNT;i++){
        const struct field_rule *r=&rules[i];struct xmd_field *f=&out->fields[i];f->tag=r->tag;
        const struct xmd_native_value *v=get_by_id(container,(int32_t)r->tag,__FILE__,__func__,__LINE__);
        if(!v)continue;
        struct xmd_native_value header;memcpy(&header,v,sizeof header);
        f->native_type=header.type;f->native_count=header.count;
        if(header.type!=r->type||header.count<r->min_count||header.count>r->max_count){f->state=XMD_SHAPE_MISMATCH;continue;}
        if(!header.data){f->state=XMD_NULL_DATA;continue;}
        uint32_t bytes=r->prefix_bytes?r->prefix_bytes:(uint32_t)header.count*r->width;
        if(bytes>XMD_DATA_BYTES){f->state=XMD_SHAPE_MISMATCH;continue;}
        memcpy(f->data,header.data,bytes);f->copied_bytes=bytes;f->state=XMD_COPIED;
    }
    out->state=XMD_OK;
    /* exact_exposure_frame_match_proven deliberately remains0. */
    return XMD_OK;
}
