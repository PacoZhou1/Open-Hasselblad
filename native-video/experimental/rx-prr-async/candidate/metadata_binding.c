#define _GNU_SOURCE 1
#include "metadata_binding.h"
#include "metadata_entry_pin.h"
#include <errno.h>
#include <string.h>
#include <stdio.h>
#include <stddef.h>
/* Existing Bionic ELF64 phdr ABI, also used by the MODE21 descriptor guard.
 * Read existing mappings only, with controller whole-file identity gate. */
typedef struct { uint32_t type,flags; uint64_t offset,vaddr,paddr,filesz,memsz,align; } XmdPhdr;
typedef struct { uintptr_t addr; const char *name; const XmdPhdr *phdr; uint16_t phnum; } XmdPhdrInfo;
extern int dl_iterate_phdr(int (*)(XmdPhdrInfo *,size_t,void *),void *);
static xmd_get_by_id_fn getter;
struct binding { void *entry; unsigned seen; int error; };
static int inspect_loaded(XmdPhdrInfo *i,size_t size,void *opaque){
 struct binding *b=opaque;
 if(size<offsetof(XmdPhdrInfo,phnum)+sizeof(i->phnum)||!i->name)return 0;
 const char *name=strrchr(i->name,'/');name=name?name+1:i->name;
 if(strcmp(name,"libdcam_base.so"))return 0;
 if(++b->seen!=1){b->error=EPROTO;return 0;}
 if(!i->phdr||!i->phnum||i->phnum>64||i->addr>UINTPTR_MAX-XMD_GET_BY_ID_RELATIVE_VA-64){b->error=EPROTO;return 0;}
 unsigned header=0,executable=0;
 for(unsigned n=0;n<i->phnum;n++){
  const XmdPhdr *p=&i->phdr[n];if(p->type!=1)continue;
  if(p->offset==0&&p->vaddr==0x1000)header=1;
  if((p->flags&7)==5&&p->vaddr<=XMD_GET_BY_ID_RELATIVE_VA&&p->memsz>=64&&XMD_GET_BY_ID_RELATIVE_VA-p->vaddr<=p->memsz-64)executable=1;
 }
 if(!header||!executable){b->error=EPROTO;return 0;}
 void *p=(void *)(i->addr+XMD_GET_BY_ID_RELATIVE_VA);
 if(memcmp(p,xmd_get_by_id_entry64,sizeof xmd_get_by_id_entry64)){b->error=EPROTO;return 0;}
 b->entry=p;return 0; /* Continue to detect ambiguous same-basename mappings. */
}
int xmd_bind_getter(void){
 struct binding b={0};int rc=dl_iterate_phdr(inspect_loaded,&b);
 if(rc||b.error||b.seen!=1||!b.entry){fprintf(stderr,"XMD_BIND phdr_reject iterator=%d matches=%u error=%d\n",rc,b.seen,b.error);return b.error?b.error:EINVAL;}
 memcpy(&getter,&b.entry,sizeof getter);fprintf(stderr,"XMD_BIND pinned phdr_library relative=0x114c50\n");return 0;
}
int xmd_sample_pinned_frame(const void *frame,struct xmd_snapshot *out){return xmd_sample_borrowed_frame(frame,0x3b0,getter!=NULL,getter,out);}
#ifdef X2V_HOST_TEST
void xmd_test_bind_getter(xmd_get_by_id_fn p){getter=p;}
#endif
