#ifndef X2V_RESIDENT_HOOK_H
#define X2V_RESIDENT_HOOK_H
#include <stddef.h>
#include <stdint.h>
struct x2v_receiver;
struct x2v_hook_clip;
int x2v_hook_bind(void);
struct x2v_hook_clip *x2v_hook_clip_new(struct x2v_receiver *,uint64_t generation);
int x2v_hook_open(struct x2v_hook_clip *);
void x2v_hook_close(struct x2v_hook_clip *);
int x2v_receiver_callback_active(struct x2v_hook_clip *);
int x2v_receiver_vendor_error(struct x2v_hook_clip *);
size_t x2v_hook_json(struct x2v_hook_clip *,char *,size_t);
#endif
