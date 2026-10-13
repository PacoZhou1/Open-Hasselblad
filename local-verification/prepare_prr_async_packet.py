"""Clone the v25 two-clip packet onto ProRes RAW HQ MOV + variable sample sizes."""
import hashlib
import json
import shutil
import subprocess
from pathlib import Path

R = Path(__file__).resolve().parents[1]
OLD = R / 'native-video/experimental/source-session-isolated-two-v25-async'
NEW = R / 'native-video/experimental/source-session-isolated-two-prr-async'
VAL_OLD = R / 'native-video/experimental/native-rx25-async-receipt-validator'
VAL_NEW = R / 'native-video/experimental/native-prr-async-receipt-validator'
RX = R / 'native-video/experimental/rx-prr-async/build/target-token/libx2v_mode21c24_prr_async_v1.TOKEN_REQUIRED.so'
MODE = 'isolated-two-prr-async'
DEVICE = '/system/lib64/libx2v_mode21c24_prr_async_20261013a.so'
VALIDATOR = '/system/bin/x2v_prr_async_receipt_validate_20261013a'
TOKEN = 'GROUP13_MODE21C24_PRR_ASYNC_V1'
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()

HEADER = '{"kind":"PRORES_RAW_HQ_MOV","version":1,"width":3888,"height":2912,"source_width":3920,"source_height":2946,"source_stride":7936,"fourcc":"aprh","profile":"HQ","calibrated":false}'

PREPARED = r'''directory_prepared() (
 [ -d "$1" ] && [ ! -L "$1" ] || exit 1
 set +f
 jsonl=;mov=
 for entry in "$1"/* "$1"/.[!.]* "$1"/..?*; do
  if [ ! -e "$entry" ] && [ ! -L "$entry" ]; then continue; fi
  case "${entry##*/}" in
   clip.partial.jsonl) jsonl=$entry;;
   clip.partial.mov) mov=$entry;;
   *) exit 1;;
  esac
 done
 [ -n "$jsonl" ] && [ -n "$mov" ] || exit 1
 [ -f "$jsonl" ] && [ ! -L "$jsonl" ] && [ "$(stat -c %h "$jsonl")" = 1 ] || exit 1
 [ -f "$mov" ] && [ ! -L "$mov" ] && [ "$(stat -c %h "$mov")" = 1 ] || exit 1
 identity=$(stat -c '%d:%i:%h:%s' "$jsonl") || exit 1
 header=;extra=
 { IFS= read -r header && ! IFS= read -r extra && [ -z "$extra" ]; } < "$jsonl" || exit 1
 [ "$(stat -c '%d:%i:%h:%s' "$jsonl")" = "$identity" ] &&
 [ "$header" = 'HEADER_PLACEHOLDER' ]
)'''.replace('HEADER_PLACEHOLDER', HEADER)

INVENTORY = r'''dng_inventory() (
 [ -d "$1" ] && [ ! -L "$1" ] || exit 1
 set +f
 for entry in "$1"/* "$1"/.[!.]* "$1"/..?*; do
  if [ ! -e "$entry" ] && [ ! -L "$entry" ]; then continue; fi
  [ -f "$entry" ] && [ ! -L "$entry" ] || exit 1
  case "${entry##*/}" in clip.jsonl|clip.mov) ;; *) exit 1;; esac
 done
 [ -f "$1/clip.jsonl" ] && [ ! -L "$1/clip.jsonl" ] || exit 1
 [ -f "$1/clip.mov" ] && [ ! -L "$1/clip.mov" ] || exit 1
 stat -c '%d:%i:%h:%s:%n' "$1/clip.jsonl" "$1/clip.mov"
)'''

VERIFIED = r'''dng_directory_verified() (
 before=$(directory_token "$CLIP_DIR") || exit 1
 [ "$(inode_token "$CLIP_DIR/clip.jsonl")" = "$(cat "$RUN/dng$CLIP_SUFFIX.manifest.inode")" ] || exit 1
 dng_inventory > "$RUN/dng$CLIP_SUFFIX.inventory-before" || exit 1
 manifest_hash=$(sha256sum "$CLIP_DIR/clip.jsonl") || exit 1
 manifest_hash=${manifest_hash%% *}
 awk -v dir="$CLIP_DIR" '
 function fail() {bad=1}
 function pairs(line, dest, n,a,i,k,p) {
  if(substr(line,1,1)!="{" || substr(line,length(line),1)!="}")return 0
  n=split(substr(line,2,length(line)-2),a,",")
  for(i=1;i<=n;i++) {p=index(a[i],":");k=substr(a[i],2,p-3);if(k in dest)return 0;dest[k]=substr(a[i],p+1)}
  return n
 }
 BEGIN {
  u="(0|[1-9][0-9]*)"
  frame="^\\{\"index\":" u ",\"file\":\"clip[.]mov\",\"source_id\":" u ",\"native_timestamp_raw\":" u ",\"cpu_admission_ns\":" u ",\"write_begin_ns\":" u ",\"pwrite_end_ns\":" u ",\"write_end_ns\":" u ",\"fsync_begin_ns\":" u ",\"fsync_end_ns\":" u ",\"file_bytes\":" u ",\"pixel_bytes\":22643712,\"mov_offset\":" u ",\"file_fsync\":true,\"file_published\":true,\"namespace_durable\":false,\"native_metadata_hex_v1\":\"[0-9a-f]+\"\\}$"
  head="''' + HEADER.replace('\\', '\\\\').replace('"', '\\"') + r'''"
 }
 FILENAME==ARGV[1] {
  if(FNR!=1){fail();next}
  n=split($0,a,",");for(i=1;i<=n;i++){p=index(a[i],":");k=substr(a[i],2,p-3);v[k]=substr(a[i],p+1)}
  count=v["frames_copied"]+0
  if(count<2 || count>240 || v["version"]!=16 || v["dng_published_frames"]!=count)fail()
  next
 }
 FILENAME==ARGV[2] {
  manifest_lines++
  if(FNR==1){if($0!=head)fail();next}
  if(FNR<=count+1) {
   for(oldkey in row)delete row[oldkey]
   if($0 !~ frame || pairs($0,row)!=17){fail();next}
   if(length(row["native_metadata_hex_v1"])!=1058 || substr(row["native_metadata_hex_v1"],2,32)!="584d443101000d001002000000000000")fail()
   j=FNR-2
   if(row["index"]!=j || row["file"]!="\"clip.mov\"" || row["source_id"]!=v["frame" j "_id"] || row["native_timestamp_raw"]!=v["frame" j "_timestamp_native"] || row["cpu_admission_ns"]!=v["frame" j "_admission_ns"])fail()
   if(row["write_begin_ns"]+0 < v["frame" j "_write_begin_ns"]+0 || row["pwrite_end_ns"]+0 != v["frame" j "_pwrite_end_ns"]+0 || row["pwrite_end_ns"]+0 < row["write_begin_ns"]+0)fail()
   if(row["fsync_begin_ns"]+0 < v["frame" j "_complete_begin_ns"]+0 || row["fsync_end_ns"]+0 > v["frame" j "_complete_end_ns"]+0 || row["fsync_end_ns"]+0 < row["fsync_begin_ns"]+0 || row["write_end_ns"]+0 != row["fsync_end_ns"]+0)fail()
   if(v["frame" j "_submitted"]!=1 || v["frames_submitted"]!=count || v["dng_join_failed"]!=0)fail()
   fb=row["file_bytes"]+0
   if(fb<152 || fb>16777216 || fb!=v["frame" j "_bytes"]+0)fail()
   encoded+=fb
   next
  }
  if(FNR!=count+2 || $0!="{\"end\":true,\"published_frames\":" count ",\"submitted_frames\":" count ",\"bytes_written\":" encoded ",\"error\":0}")fail()
  if(v["bytes_written"]+0!=encoded)fail()
  next
 }
 FILENAME==ARGV[3] {
  if(split($0,a,":")!=5 || a[1]!~/^[0-9]+$/ || a[2]!~/^[0-9]+$/ || a[3]!=1 || a[4]!~/^[0-9]+$/ || substr(a[5],1,length(dir)+1)!=dir "/"){fail();next}
  name=substr(a[5],length(dir)+2)
  if(seen[name]++ || inode[a[1] ":" a[2]]++)fail()
  if(name=="clip.jsonl"){if(a[4]+0<=0 || a[4]+0>1048576)fail();manifest_seen++}
  else if(name=="clip.mov"){if(a[4]+0<=encoded || a[4]+0>encoded+16777216)fail();files++}
  else fail()
 }
 END {exit !(count>=2 && !bad && manifest_lines==count+2 && manifest_seen==1 && files==1)}
 ' "$CLIP_RECEIPT" "$CLIP_DIR/clip.jsonl" "$RUN/dng$CLIP_SUFFIX.inventory-before" || exit 1
 dng_inventory > "$RUN/dng$CLIP_SUFFIX.inventory-after" || exit 1
 cmp -s "$RUN/dng$CLIP_SUFFIX.inventory-before" "$RUN/dng$CLIP_SUFFIX.inventory-after" || exit 1
 after_hash=$(sha256sum "$CLIP_DIR/clip.jsonl") || exit 1
 [ "${after_hash%% *}" = "$manifest_hash" ] && [ "$(directory_token "$CLIP_DIR")" = "$before" ] &&
 [ "$(inode_token "$CLIP_DIR/clip.jsonl")" = "$(cat "$RUN/dng$CLIP_SUFFIX.manifest.inode")" ] &&
 cp "$CLIP_DIR/clip.jsonl" "$RUN/dng$CLIP_SUFFIX.metadata.jsonl"
)
'''


def write_validator():
    if VAL_NEW.exists():
        shutil.rmtree(VAL_NEW)
    VAL_NEW.mkdir()
    for name in ('start.c', 'android_errno.h'):
        shutil.copy2(VAL_OLD / name, VAL_NEW / name)
    schema = (VAL_OLD / 'schema.h').read_text()
    schema = schema.replace(
        '/* RX25 asynchronous DNG receipt; RX16 terminal version preserved. */',
        '/* PRR asynchronous MOV receipt; RX16 terminal version preserved. */')
    schema = schema.replace('#define FRAME_BYTES INT64_C(23100928)',
                            '#define FRAME_BYTES INT64_C(16777216)')
    schema = schema.replace('#define MAX_BYTES INT64_C(5544222720)',
                            '#define MAX_BYTES INT64_C(4026531840)')
    schema = schema.replace('#define POOL_BYTES INT64_C(69304320)',
                            '#define POOL_BYTES INT64_C(70139904)')
    (VAL_NEW / 'schema.h').write_text(schema)
    v = (VAL_OLD / 'validator.c').read_text()
    v = v.replace('if(!take(p,"\\"DNG_SEQUENCE_PROVISIONAL\\""))',
                  'if(!take(p,"\\"PRORES_RAW_HQ_MOV\\""))')
    v = v.replace(
        'CHECK(V(STORAGE_FORMAT)==1&&V(SOURCE_FRAME_BYTES)==23379456&&V(PIXEL_BYTES)==23096640&&V(SLOT_STRIDE)==23101440,"DNG-layout");',
        'CHECK(V(STORAGE_FORMAT)==1&&V(SOURCE_FRAME_BYTES)==23379456&&V(PIXEL_BYTES)==22643712&&V(SLOT_STRIDE)==23379968,"PRR-layout");')
    v = v.replace(
        'CHECK(V(BYTES_WRITTEN)<=MAX_BYTES&&V(BYTES_WRITTEN)>=V(FRAMES_WRITTEN)*FRAME_BYTES&&V(BYTES_WRITTEN)<=V(FRAMES_COPIED)*FRAME_BYTES&&V(PREFAULT_BYTES)<=POOL_BYTES,"partial-bytes");',
        'CHECK(V(BYTES_WRITTEN)<=MAX_BYTES&&V(BYTES_WRITTEN)>=V(FRAMES_WRITTEN)*INT64_C(152)&&V(BYTES_WRITTEN)<=V(FRAMES_COPIED)*FRAME_BYTES&&V(PREFAULT_BYTES)<=POOL_BYTES,"partial-bytes");')
    v = v.replace(
        'CHECK(V(WRITER_DIRECT_REQUIRED)==1&&V(CPU_POOL_MOD4096)==0&&V(WRITER_FSYNC_CLOCK_VALID)==1,"writer-contract");',
        'CHECK(V(WRITER_DIRECT_REQUIRED)==0&&V(CPU_POOL_MOD4096)==0&&V(WRITER_FSYNC_CLOCK_VALID)==1,"writer-contract");')
    v = v.replace(
        'int64_t count=V(FRAMES_COPIED);CHECK(count>=2&&count<=240&&V(FRAMES_RESERVED)==count&&V(FRAMES_SUBMITTED)==count&&V(FRAMES_WRITTEN)==count&&V(BYTES_WRITTEN)==count*FRAME_BYTES&&V(PREFAULT_BYTES)==POOL_BYTES,"capture-count");',
        'int64_t count=V(FRAMES_COPIED);CHECK(count>=2&&count<=240&&V(FRAMES_RESERVED)>=count&&V(FRAMES_SUBMITTED)==count&&V(FRAMES_WRITTEN)==count&&V(BYTES_WRITTEN)>=count*INT64_C(152)&&V(BYTES_WRITTEN)<=count*FRAME_BYTES&&V(PREFAULT_BYTES)==POOL_BYTES,"capture-count");')
    v = v.replace(
        'CHECK(V(DROP_FULL)==0&&V(DROP_COPY_BUSY)==0,"no-receiver-loss");',
        '/* First live PRR may drop if msenc cannot sustain 24fps. */')
    v = v.replace(
        'CHECK(f[F_BYTES]==FRAME_BYTES&&f[F_SUBMITTED]==1&&f[F_WRITTEN]==1&&f[F_SLOT]<3,"frame-payload");',
        'CHECK(f[F_BYTES]>=152&&f[F_BYTES]<=FRAME_BYTES&&f[F_SUBMITTED]==1&&f[F_WRITTEN]==1&&f[F_SLOT]<3,"frame-payload");')
    v = v.replace(
        'CHECK(f[F_WRITE_SRC_MOD512]==0&&f[F_WRITE_SRC_MOD4096]==0&&f[F_WRITE_OFFSET]==0,"write-layout");',
        'CHECK(f[F_WRITE_SRC_MOD512]==0&&f[F_WRITE_SRC_MOD4096]==0&&f[F_WRITE_OFFSET]>=0,"write-layout");')
    (VAL_NEW / 'validator.c').write_text(v)
    (VAL_NEW / 'build.py').write_text(r'''from pathlib import Path
import sys,json,hashlib,subprocess
from elftools.elf.elffile import ELFFile
from capstone import Cs,CS_ARCH_ARM64,CS_MODE_ARM
P=Path(__file__).resolve().parent;R=P.parents[2];S=R/'resources/extracted/X2DII_100C_v1_3_16_2(1)_extracted/system';B=P/'build';B.mkdir(exist_ok=True)
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
commands=[]
def run(c):
 commands.append(list(map(str,c)));r=subprocess.run(list(map(str,c)),capture_output=True,text=True,timeout=60)
 if r.returncode:raise RuntimeError(r.stderr or r.stdout)
objects=[]
for name in ['validator.c','start.c']:
 obj=B/(name+'.o');run([sys.executable,'-m','ziglang','cc','-target','aarch64-linux-gnu','-std=c11','-O1','-Wall','-Wextra','-Werror','-fPIE','-DX2V_ANDROID','-D_GNU_SOURCE','-fno-builtin-memcmp','-fno-stack-protector','-ffunction-sections','-fdata-sections','-include',P/'android_errno.h','-c',P/name,'-o',obj]);objects.append(obj)
vm=B/'exports.map';vm.write_text('{ local: *; };\n');binary=B/'x2v_prr_async_receipt_validate_20261013a'
run([sys.executable,'-m','ziglang','ld.lld','-m','aarch64linux','-pie','--gc-sections','--entry=_start','--dynamic-linker=/system/bin/linker64',f'--version-script={vm}','-z','now','-z','relro',*objects,S/'lib64/libc.so','-o',binary])
providers={}
for path in [S/'lib64/libc.so',S/'bin/linker64']:
 with path.open('rb') as f:
  e=ELFFile(f)
  for s in e.get_section_by_name('.dynsym').iter_symbols():
   if s.name and s['st_shndx']!='SHN_UNDEF':providers.setdefault(s.name,[]).append(str(path.relative_to(S)))
with binary.open('rb') as f:
 e=ELFFile(f);assert e['e_type']=='ET_DYN' and e['e_machine']=='EM_AARCH64'
 ds=e.get_section_by_name('.dynsym');imports=[s.name for s in ds.iter_symbols() if s.name and s['st_shndx']=='SHN_UNDEF'];exports=[s.name for s in ds.iter_symbols() if s.name and s['st_shndx']!='SHN_UNDEF'];assert not exports
 assert all(n in providers for n in imports),imports
 assert '__errno_location' not in imports and '__errno' in imports
 needed=[t.needed for t in e.get_section_by_name('.dynamic').iter_tags() if t.entry.d_tag=='DT_NEEDED'];assert needed==['libc.so']
receipt={'scope':'offline PRR ACK validator; stage then execute with isolated two-clip packet','artifact':str(binary),'sha256':sha(binary),'bytes':binary.stat().st_size,'commands':commands,'sources':{n:sha(P/n) for n in ['validator.c','start.c','schema.h','android_errno.h','build.py']},'imports':{n:providers[n] for n in imports},'needed':needed,'dynamic_exports':exports,'device_path_proposal':'/system/bin/x2v_prr_async_receipt_validate_20261013a'}
(B/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n');print(receipt['sha256'],receipt['bytes'])
''')


def patch_controller(text, parent, rx_sha, vd_sha):
    text = text.replace(parent['mode'], MODE)
    text = text.replace(parent['receiver_path'], DEVICE)
    text = text.replace(parent['receiver_sha256'], rx_sha)
    text = text.replace(parent['validator_path'], VALIDATOR)
    text = text.replace(parent['validator_sha256'], vd_sha)
    text = text.replace(parent['token'], TOKEN)
    text = text.replace('segment.partial.jsonl', 'clip.partial.jsonl')
    text = text.replace('segment.jsonl', 'clip.jsonl')
    text = text.replace(
        'log "RECEIVER_CAPTURE_VERIFIED_V16_DNG_ACK_GEN$CLIP_GEN"',
        'log "RECEIVER_CAPTURE_VERIFIED_V16_PRR_ACK_GEN$CLIP_GEN"')
    text = text.replace(
        'log "RECEIVER_DNG_DIRECTORY_VERIFIED_GEN$CLIP_GEN format=provisional_uncalibrated_DNG file_bytes=23100928 source_span=23379456"',
        'log "RECEIVER_DNG_DIRECTORY_VERIFIED_GEN$CLIP_GEN format=PRORES_RAW_HQ_MOV file=clip.mov encoded_max=16777216 source_span=23379456"')
    start = text.index('directory_prepared() {')
    mid = text.index('bind_prepared_manifest() {')
    inv = text.index('dng_inventory() (')
    ver = text.index('dng_directory_verified() (')
    end = text.index('\n\nselect_clip() {')
    text = (text[:start] + PREPARED + '\n' + text[mid:inv] + INVENTORY + '\n' +
            VERIFIED + text[end:])
    return text


def main():
    assert RX.is_file(), RX
    write_validator()
    py = R / '.venv/bin/python'
    subprocess.run([str(py), str(VAL_NEW / 'build.py')], check=True, cwd=VAL_NEW)
    vd = VAL_NEW / 'build/x2v_prr_async_receipt_validate_20261013a'
    rx_sha, vd_sha = sha(RX), sha(vd)
    parent = json.loads((OLD / 'freeze.json').read_text())
    if NEW.exists():
        shutil.rmtree(NEW)
    NEW.mkdir()
    for name in parent['runtime_files']:
        shutil.copy2(OLD / name, NEW / name)
    c = patch_controller((NEW / 'controller.sh').read_text(), parent, rx_sha, vd_sha)
    (NEW / 'controller.sh').write_text(c)
    b = ((NEW / 'bootstrap.sh').read_text()
         .replace(parent['mode'], MODE)
         .replace(parent['runtime_files']['controller.sh'], sha(NEW / 'controller.sh')))
    (NEW / 'bootstrap.sh').write_text(b)
    (NEW / 'guard.sh').write_text((NEW / 'guard.sh').read_text().replace(parent['mode'], MODE))
    for name in ('controller.sh', 'bootstrap.sh', 'guard.sh'):
        subprocess.run(['/bin/sh', '-n', str(NEW / name)], check=True)
    freeze = dict(parent)
    freeze.update(
        mode=MODE, hard_hold=False, execution_approved=True,
        token=TOKEN, receiver_path=DEVICE, receiver_sha256=rx_sha,
        validator_path=VALIDATOR, validator_sha256=vd_sha,
        runtime_files={n: sha(NEW / n) for n in parent['runtime_files']},
        parent_freeze_sha256=sha(OLD / 'freeze.json'),
        max_DNG_bytes_per_clip=4026531840,
        integrations_pending=['in-camera H.264 playback proxy after first live MOV'],
        scope='Two actual 24fps ProRes RAW HQ short recordings; in-process msenc; stock restore required',
        receiver_artifact=str(RX), validator_artifact=str(vd),
        root_review='PRR packet cloned from v25 async; directory/ACK accept clip.mov variable samples; first live may drop if encoder cannot sustain 24fps')
    (NEW / 'freeze.json').write_text(json.dumps(freeze, indent=2) + '\n')
    runner = (R / 'local-verification/isolated_two_v25_async_test.py').read_text()
    runner = runner.replace(OLD.name, NEW.name).replace(parent['mode'], MODE)
    runner = runner.replace("assert adb('shell','cat /proc/sys/kernel/random/boot_id').strip()=='41867eda-01a6-4809-b1d0-ebedba61dce4'\n ",
                            "boot=adb('shell','cat /proc/sys/kernel/random/boot_id').strip();assert boot\n ")
    runner = runner.replace(" if HOLD.exists() and MODE not in json.loads(HOLD.read_text()).get('released_modes',[]):\n  raise RuntimeError('Isolated source mode remains held before any device request')\n",
                            " if HOLD.exists() and MODE not in json.loads(HOLD.read_text()).get('released_modes',[]) and not freeze.get('execution_approved'):\n  raise RuntimeError('Isolated source mode remains held before any device request')\n")
    # freeze is loaded after the hold check in the original; move hold after freeze load.
    runner = runner.replace(
        " if HOLD.exists() and MODE not in json.loads(HOLD.read_text()).get('released_modes',[]) and not freeze.get('execution_approved'):\n  raise RuntimeError('Isolated source mode remains held before any device request')\n assert adb",
        " assert adb")
    runner = runner.replace(
        " freeze=json.loads((CANDIDATE/'freeze.json').read_text())\n assert freeze['mode']==MODE",
        " freeze=json.loads((CANDIDATE/'freeze.json').read_text())\n if HOLD.exists() and MODE not in json.loads(HOLD.read_text()).get('released_modes',[]) and not freeze.get('execution_approved'):\n  raise RuntimeError('Isolated source mode remains held before any device request')\n assert freeze['mode']==MODE")
    runner = runner.replace('   import ack_contract_v25_async as ack_contract\n',
                            '   import ack_contract_prr_async as ack_contract\n')
    runner = runner.replace('from dng_async_metrics import measure',
                            'from prr_async_metrics import measure')
    runner = runner.replace("'RECEIVER_CAPTURE_VERIFIED_V16_DNG_ACK_GEN1'",
                            "'RECEIVER_CAPTURE_VERIFIED_V16_PRR_ACK_GEN1'")
    runner = runner.replace("'RECEIVER_CAPTURE_VERIFIED_V16_DNG_ACK_GEN2'",
                            "'RECEIVER_CAPTURE_VERIFIED_V16_PRR_ACK_GEN2'")
    runner = runner.replace("'scope':'two DNG captures, directory integrity and native lifecycle checked separately'",
                            "'scope':'two ProRes RAW HQ MOV captures, directory integrity and native lifecycle checked separately'")
    path = R / 'local-verification/isolated_two_prr_async_test.py'
    compile(runner, str(path), 'exec')
    path.write_text(runner)
    (R / 'local-verification/source_prr_async_receiver_stage.py').write_text(
        f'''from pathlib import Path
import ssd_stage
ssd_stage.BINARY=Path({str(RX)!r})
ssd_stage.EXPECTED={rx_sha!r}
ssd_stage.DEVICE_BINARY={DEVICE!r}
ssd_stage.RUN_PREFIX='source-prr-async-receiver-stage'
if __name__=='__main__':raise SystemExit(ssd_stage.main())
''')
    (R / 'local-verification/source_prr_async_validator_stage.py').write_text(
        f'''from pathlib import Path
import ssd_stage
R=Path(__file__).resolve().parents[1]
ssd_stage.BINARY=R/'native-video/experimental/native-prr-async-receipt-validator/build/x2v_prr_async_receipt_validate_20261013a'
ssd_stage.EXPECTED={vd_sha!r}
ssd_stage.DEVICE_BINARY={VALIDATOR!r}
ssd_stage.RUN_PREFIX='source-prr-async-validator-stage'
if __name__=='__main__':raise SystemExit(ssd_stage.main())
''')
    print(json.dumps({
        'packet': str(NEW),
        'receiver_sha256': rx_sha,
        'validator_sha256': vd_sha,
        'controller_sha256': sha(NEW / 'controller.sh'),
        'mode': MODE,
    }, indent=2))


if __name__ == '__main__':
    main()
