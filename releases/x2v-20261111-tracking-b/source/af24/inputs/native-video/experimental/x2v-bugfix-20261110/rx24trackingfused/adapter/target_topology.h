#ifndef X2V_TARGET_TOPOLOGY_H
#define X2V_TARGET_TOPOLOGY_H
#include <stdint.h>
struct x2v_target_topology {
 struct {uint32_t count,pad;uintptr_t rows;} header;
 _Alignas(8) unsigned char rows[7*0x640];
 _Alignas(8) unsigned char ports[40*0x50];
};
int x2v_target_topology_clone(struct x2v_target_topology *,const void *cam_info,int mode21);
int x2v_target_active_rect(const struct x2v_target_topology *,int profile,void *rect10);
#endif
