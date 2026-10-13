#ifndef X2V_COPY_PROVIDER_H
#define X2V_COPY_PROVIDER_H
#include <stddef.h>
/* Own constructor/main only. Exact already-loaded native libc provider.
 * No vendor initializer, offset lookup, fallback or symbol interposition. */
int x2v_copy_provider_bind(void);
int x2v_copy_provider_pinned(void);
int x2v_copy_bytes(void *dst,const void *src,size_t length);
size_t x2v_copy_provider_json(char *,size_t);
#endif
