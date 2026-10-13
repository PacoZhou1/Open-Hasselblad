#ifndef XMD_BINDING_H
#define XMD_BINDING_H
#include "metadata_sample.h"
int xmd_bind_getter(void);
int xmd_sample_pinned_frame(const void *,struct xmd_snapshot *);
#ifdef X2V_HOST_TEST
void xmd_test_bind_getter(xmd_get_by_id_fn);
#endif
#endif
