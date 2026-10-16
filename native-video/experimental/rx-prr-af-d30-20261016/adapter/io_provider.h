#ifndef X2V_WRITER_PROVIDER_H
#define X2V_WRITER_PROVIDER_H
#include <stddef.h>
#include <sys/types.h>
_Static_assert(sizeof(off_t)==8,"64-bit pwrite offset required");
int x2v_writer_provider_bind(void);
int x2v_writer_provider_pinned(void);
ssize_t x2v_writer_pwrite(int,const void*,size_t,off_t);
int x2v_writer_fsync(int);
size_t x2v_writer_provider_json(char*,size_t);
#endif
