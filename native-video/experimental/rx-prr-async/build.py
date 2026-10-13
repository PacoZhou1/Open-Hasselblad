#!/usr/bin/env python3
"""Own source compile + vendor ELF inspection only. Never load vendor code."""
import argparse,hashlib,json,subprocess,sys
from pathlib import Path
from elftools.elf.elffile import ELFFile
from capstone import Cs,CS_ARCH_ARM64,CS_MODE_ARM
ap=argparse.ArgumentParser();ap.add_argument('--kind',choices=['target-token'],required=True);args=ap.parse_args()
HERE=Path(__file__).resolve().parent
R=Path('/Users/paco/Documents/ChatGPT/哈苏');P=HERE/'candidate';BASE_SOURCE=Path('/Users/paco/Documents/ChatGPT/哈苏/native-video/experimental/source-receiver-adapter/receiver_v18_dng_isp_proxy');A=BASE_SOURCE.parent
H=R/'research/full-fov-pipeline/source-adapter';S=R/'resources/extracted/X2DII_100C_v1_3_16_2(1)_extracted/system'
ENC=R/'native-video/experimental/prores-raw-encoder'
OWNED={'receiver.c','dng_prepacked.c','dng_prepacked.h','shape.h','debug_hub_guard.c'}
B=HERE/'build'/args.kind;B.mkdir(parents=True,exist_ok=True);G=R/'native-video/experimental/resident-raw-clip-state'
def candidate_source(name):
 p=P/name
 return p if p.exists() else BASE_SOURCE/name
candidate_manifest=json.loads((HERE/'candidate-manifest.json').read_text())

assert args.kind=='target-token'
shape={'carrier':0,'raw-normal':1,'raw-target':2,'target-off':2,'target-token':2}[args.kind];combined=args.kind.startswith('target-');allow=args.kind=='target-token';commands=[]
def run(c):
 commands.append(list(map(str,c)));r=subprocess.run(list(map(str,c)),capture_output=True,text=True,timeout=60)
 if r.returncode:raise RuntimeError(r.stderr)

sources=[candidate_source(n) for n in ['receiver.c','vendor_hook.c','control.c','copy_provider.c','io_provider.c','dng_prepacked.c','debug_hub_guard.c','frame_writer.c','android_abi_check.c','geometry.c','color_observer.c','metadata_sample.c','metadata_binding.c','metadata_record.c']]+[A/'android_stat_check.c',G/'clip_gate.c']+[ENC/n for n in ['prr_hal.c','prr_pre.c','prr_enc.c','prr_mov.c']]
if combined:sources += [candidate_source('target_start_gate.c'),candidate_source('target_parser_gate.c')] + [candidate_source(n) for n in ['target_topology.c','graph_binding.c','hal_topology_glue.c','fps_guard_session.c']]+[candidate_source('source_mode21_guard_preload.c'),H/'owned_descriptor.c',H/'hal_profile_adapter.c',candidate_source('target_descriptor.c')]
# C24 review pins + unchanged native provider/helper pins; no vendor code loading.
base_freeze=json.loads((A/'receiver_v7_target_filter_port/freeze.json').read_text())
for rel,h in base_freeze['unchanged_target_shared_headers'].items():assert hashlib.sha256((R/rel).read_bytes()).hexdigest()==h,rel
review=json.loads((A/'target_engine_owner_review/review-receipt-v2.json').read_text())
geometry_review=json.loads((A/'target_topology_geometry_review/review-receipt.json').read_text())
sequence_review=json.loads((BASE_SOURCE/'source-review.json').read_text())
fullrect_freeze=json.loads((A/'receiver_v7_target_fullrect/freeze.json').read_text())
# Verify original source freeze, the private candidate and unchanged shared helpers.
for n,h in sequence_review['production_sources'].items():assert hashlib.sha256((BASE_SOURCE/n).read_bytes()).hexdigest()==h,n
for n,h in sequence_review['headers'].items():assert hashlib.sha256((BASE_SOURCE/n).read_bytes()).hexdigest()==h,n
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
for n,h in candidate_manifest['baseline_sha256'].items():assert sha(BASE_SOURCE/n)==h,n
for n,h in candidate_manifest['candidate_sources'].items():
 if n not in OWNED:assert sha(P/n)==h,n
gate_freeze=json.loads((G/'freeze.json').read_text())
assert sha(G/'freeze.json')==sequence_review['clip_gate_freeze_sha256']
for name in ['clip_gate.c','clip_gate.h']:assert sha(G/name)==gate_freeze['files'][name]
for src in sources:
 if src.parent==ENC or src.name in OWNED:continue
 rel=str(src.relative_to(R))
 expected=candidate_manifest['candidate_sources'][src.name] if src.parent==P else sequence_review['production_sources'][src.name] if src.parent==BASE_SOURCE else gate_freeze['files'][src.name] if src.parent==G else base_freeze['unchanged_target_shared_sources'][rel]
 assert sha(src)==expected,rel
z=[sys.executable,'-m','ziglang','cc','-target','aarch64-linux-gnu'];objects=[]
for i,src in enumerate(sources):
 obj=B/f'{i}-{src.name}.o';flags=['-std=c11','-Wall','-Wextra','-Werror','-fPIC','-O1','-fno-stack-protector','-fno-builtin-memcmp','-ffunction-sections','-fdata-sections','-D_GNU_SOURCE','-DX2V_ANDROID',f'-DX2V_SHAPE={shape}','-I',H,'-I',A,'-I',G,'-I',P,'-I',BASE_SOURCE,'-I',ENC,'-include',A/'android_errno.h']
 if combined:flags+=['-DX2V_ENABLE_MODE21_PROFILE=1',f'-DX2V_ALLOW_MODE21_START={int(allow)}']
 run([*z,*flags,'-c',src,'-o',obj]);objects.append(obj)
def export_version(file,name):
 with file.open('rb') as f:
  e=ELFFile(f);ds=e.get_section_by_name('.dynsym');index=next(i for i,s in enumerate(ds.iter_symbols()) if s.name==name and s['st_shndx']!='SHN_UNDEF');v=e.get_section_by_name('.gnu.version').get_symbol(index)['ndx']
  if isinstance(v,str):return None
  names={node['vd_ndx']:next(aux).name for node,aux in e.get_section_by_name('.gnu.version_d').iter_versions()};return names[v&0x7fff]
# Keep the exact provider version of each actual interposed export. No guessed
# global namespace. Additional helper exports remain unversioned for integration.
provider_exports={'cam_filter_dump_frame_data':'lib64/libdcam_frwk.so'}
if combined:provider_exports.update({'cam_cap_eng_set_streaming_params':'lib64/libdcam_frwk.so','cam_cap_eng_start_streaming':'lib64/libdcam_frwk.so','stream_group_mgr_create':'lib64/libdcam_frwk.so','rcam_imgsys_create':'lib64/librcam.so','dlsym':'lib64/libdl.so','__open_2':'lib64/libc.so','fopen':'lib64/libc.so','inotify_add_watch':'lib64/libc.so'})
groups={}
for name,file in provider_exports.items():
 v=export_version(S/file,name)
 if v:groups.setdefault(v,[]).append(name)
version_map=B/'versions.map';version_map.write_text('\n'.join(f'{v} {{ global: '+ '; '.join(names)+'; };' for v,names in groups.items())+'\nX2V_REVIEWED_INTERNAL { global: x2v_mode21_vendor_allowed; x2v_target_parser_owner; x2v_target_parser_class; local: *; };\n')
label='TOKEN_REQUIRED' if allow else 'START_OFF' if combined else 'RECEIVER_ONLY'
artifact=B/'libx2v_mode21c24_prr_async_v1.TOKEN_REQUIRED.so'
run([*z,'-nostdlib','-shared','-Wl,--gc-sections','-Wl,--allow-shlib-undefined',f'-Wl,--version-script={version_map}',*objects,S/'lib64/libc.so',S/'lib64/libdl.so',S/'lib64/libm.so',S/'lib64/libduml_hal.so',S/'lib64/libduml_util.so',S/'lib64/libduml_vcodec.so','-o',artifact])
provider_paths=[S/'lib64/libc.so',S/'lib64/libdl.so',S/'lib64/libm.so',S/'lib64/libduml_hal.so',S/'lib64/libduml_util.so',S/'lib64/libduml_vcodec.so',S/'bin/linker64'];provider_symbols={}
for p in provider_paths:
 with p.open('rb') as f:
  e=ELFFile(f)
  for s in e.get_section_by_name('.dynsym').iter_symbols():
   if s.name and s['st_shndx']!='SHN_UNDEF':provider_symbols.setdefault(s.name,[]).append(str(p.relative_to(S)))
with artifact.open('rb') as f:
 e=ELFFile(f);d=e.get_section_by_name('.dynsym');imports=[s.name for s in d.iter_symbols() if s.name and s['st_shndx']=='SHN_UNDEF'];assert all(n in provider_symbols for n in imports)
 assert '__errno_location' not in imports
 defined_hook_count={n:sum(s.name==n and s['st_shndx']!='SHN_UNDEF' for s in d.iter_symbols()) for n in provider_exports}
 assert all(c==1 for c in defined_hook_count.values()),defined_hook_count
 expected_exports=set(provider_exports)|{'x2v_mode21_vendor_allowed','x2v_target_parser_owner','x2v_target_parser_class'}
 real_exports={s.name for s in d.iter_symbols() if s.name and s['st_shndx'] not in ['SHN_UNDEF','SHN_ABS']}
 assert real_exports==expected_exports,real_exports
 assert not any(s['st_info']['bind']=='STB_WEAK' and s['st_shndx']!='SHN_UNDEF' for s in d.iter_symbols())
 assert e['e_machine']=='EM_AARCH64'
 for n,pv in provider_exports.items():assert export_version(artifact,n)==export_version(S/pv,n),n
 versions=[{'provider':v.name,'versions':[c.name for c in aux]} for v,aux in e.get_section_by_name('.gnu.version_r').iter_versions()];assert not any('GLIBC' in n for v in versions for n in v['versions'])
 names={s['st_value']:s.name for s in e.get_section_by_name('.symtab').iter_symbols() if s['st_value']};plt=e.get_section_by_name('.plt')
 for i,r in enumerate(e.get_section_by_name('.rela.plt').iter_relocations()):names[plt['sh_addr']+32+i*16]=d.get_symbol(r['r_info_sym']).name
 s=next(s for s in e.get_section_by_name('.symtab').iter_symbols() if s.name=='cam_filter_dump_frame_data');sec=e.get_section(s['st_shndx']);off=s['st_value']-sec['sh_addr'];calls=[]
 for i in Cs(CS_ARCH_ARM64,CS_MODE_ARM).disasm(sec.data()[off:off+s['st_size']],s['st_value']):
  if i.mnemonic in ['bl','blr']:calls.append({'va':hex(i.address),'kind':i.mnemonic,'name':names.get(int(i.op_str[1:],16),'unknown') if i.mnemonic=='bl' else 'cached_native_original'})
 allowed={'xmd_sample_pinned_frame','x2v_receiver_note_native_metadata','x2v_color_observe','duss_hal_mem_get_flags','duss_hal_mem_get_fd','x2v_receiver_note_mapping','duss_hal_mem_get_size','duss_hal_mem_map','duss_hal_mem_sync_ext','duss_hal_mem_unmap','x2v_receiver_reserve','x2v_receiver_copy_reserved','x2v_receiver_finish_reserved','x2v_receiver_disarm','cached_native_original','x2v_clip_enter','x2v_clip_release'}
 assert all(c['name'] in allowed for c in calls),calls
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
receipt={'scope':'OFFLINE EXECUTION_HOLD until independent guard approved; no vendor/device execution','kind':args.kind,'artifact':str(artifact),'sha256':sha(artifact),'bytes':artifact.stat().st_size,'shape':shape,'commands':commands,'sources':{str(p.relative_to(R)):sha(p) for p in sources},'own_headers':{str(p.relative_to(R)):sha(p) for p in P.glob('*.h')},'shared_headers':dict(base_freeze['unchanged_target_shared_headers'],**{str(p.relative_to(R)):sha(p) for p in [A/'android_errno.h',A/'normal_diagnostic/diag_pins.h']}),'providers':{str(p.relative_to(S)):sha(p) for p in provider_paths},'imports':{n:provider_symbols[n] for n in imports},'interposed_export_versions':{n:export_version(artifact,n) for n in provider_exports},'provider_version_pins':{n:sha(S/file) for n,file in provider_exports.items()},'imported_versions':versions,'compiled_callback_calls':calls,'defined_hook_count':defined_hook_count,'reviewed_owner_receipt_sha256':sha(A/'target_engine_owner_review/review-receipt-v2.json'),'base_freeze_sha256':sha(A/'receiver_v7_target_fullrect/freeze.json'),'sequence_review_receipt_sha256':sha(BASE_SOURCE/'source-review.json'),'reviewed_geometry_receipt_sha256':sha(A/'target_topology_geometry_review/review-receipt.json'),'hardware_start_allow':allow,'no_token_default':'OFF; forwarding cached original only','defined_dynamic_exports':sorted(real_exports),'receipt_version':16,'clip_generations':[1,2],'clip_gate_freeze_sha256':sha(G/'freeze.json'),'max_frame_count':240,'slots':3,'admission_ns':10000000000,'constructor_ms':47000,'source_frame_bytes':23379456,'expected_frame_bytes':23100928,'slot_stride':23101440,'storage_format':'DNG_SEQUENCE_PROVISIONAL','max_total_bytes_per_clip':5544222720,'max_two_clip_bytes':11088445440,'prefault_pool_bytes':69304320,'native_stop_scope':'unchanged native controller ownership; CPU ACK is not a DMA fence','source_fps_candidate':[24,1],'HB_timing':[36000000,500,3000],'token':'GROUP13_MODE21C24_DNG_ASYNC_WRITER_V25'}
# One additional ordinary-file identity pin is required before root staging.
metadata_provider=S/'lib64/libdcam_base.so'
receipt['scope']='OFFLINE RX-PRR async writer: MODE21 source + in-process msenc ProRes RAW HQ MOV; no deployment/vendor execution'
receipt['storage_format']='PRORES_RAW_HQ_MOV'
receipt['token']='GROUP13_MODE21C24_PRR_ASYNC_V1'
receipt['slot_stride']=23379968
receipt['expected_frame_bytes']=16777216
receipt['prefault_pool_bytes']=70139904
receipt['encoded_width']=3888
receipt['encoded_height']=2912
receipt['metadata_provider_identity']={'device_path':'/system/lib64/libdcam_base.so','bytes':metadata_provider.stat().st_size,'sha256':sha(metadata_provider),'getter_relative_va':'0x114c50','entry_pin_bytes':64}
receipt['metadata_wire_schema']={'kind':'XMD1','bytes':528,'hex_chars':1056,'fields':13,'exact_exposure_frame_match_proven':0}
receipt['manifest_frame_fields']=17
receipt['async_writer']=True
receipt['async_parent_metadata_manifest_sha256']=candidate_manifest['parent_metadata_E_manifest_sha256']
receipt['new_scalar_fields']=['frames_submitted','dng_join_failed']
receipt['new_frame_fields']=['submitted','pwrite_begin_ns','pwrite_end_ns','complete_begin_ns','complete_end_ns']
receipt['metadata_allowed_permissions']=[1,3]
receipt['metadata_writer_count_required']=0
receipt['metadata_parent_candidate']='D'
receipt['full_E_receiver_lifecycle_rerun']=False
receipt['source_arm_builder_sha256']=sha(BASE_SOURCE/'build.py')
receipt['host_lifecycle_receipt_sha256']=sha(HERE/'host-verification.json')
(B/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n');print(args.kind,sha(artifact))
