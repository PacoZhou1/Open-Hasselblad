"""Bounded v12 per-frame readback after native restore; default offline."""
import argparse
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import re
import secrets
import shutil
import subprocess

from factory_session import connect
from gui_session import adb

ROOT=Path(__file__).resolve().parents[1]
PACKET=ROOT/'native-video/experimental/source-session-isolated-target-ring72-v12-c24'
HOLD=ROOT/'local-verification/source_session_execution_hold.json'
FRAME_BYTES=23379456
MAX_BYTES=FRAME_BYTES*72
RESERVE_BYTES=32*1024*1024

def sha_file(path):
    h=hashlib.sha256()
    with path.open('rb') as f:
        while data:=f.read(1024*1024):h.update(data)
    return h.hexdigest()

def validate(rx):
    spec=importlib.util.spec_from_file_location('fixed_ring72_ack_contract',PACKET/'ack_contract.py')
    module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
    return module.validate_success(rx)

def main():
    ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--run',required=True);ap.add_argument('--execute',action='store_true');args=ap.parse_args()
    if not re.fullmatch(r'source-isolated-[0-9]{6}',args.run):raise ValueError('Not a finite isolated source run')
    if not args.execute:
        print(json.dumps(dict(offline=True,run=args.run,max_bytes=MAX_BYTES,data_chunk_bytes=FRAME_BYTES)));return 0
    if HOLD.exists() and 'isolated-target-ring72-v12-c24' not in json.loads(HOLD.read_text()).get('released_modes',[]):
        raise RuntimeError('Isolated source mode remains held before any device request')
    # No execution until the pinned packet is actually frozen by root.
    freeze=json.loads((PACKET/'freeze.json').read_text())
    assert freeze['mode']=='isolated-target-ring72-v12-c24' and sha_file(PACKET/'ack_contract.py')==freeze['ack_contract_sha256']
    out=ROOT/'native-video/outputs'/args.run;report_path=out/'ring72-readback-report.json'
    if report_path.exists():raise FileExistsError('Preserve prior readback report')
    base=json.loads((out/'report.json').read_text());assert base['mode']==freeze['mode']
    result=dict(passed=False,session_passed=base['passed'],scope='Finite CPU-admitted ring frames; no sustained FPS or optical FOV claim')
    native_temp=None;host_partial=None;host_frame=None
    try:
        assert base['run_id']==args.run and base['passed'] and base['body_rc']=='0' and base['recovery_rc']=='0'
        device=out/'device-run';rx=json.loads((device/'receiver.receipt').read_text());contract=validate(rx)
        total=contract['total_bytes'];count=contract['count']
        assert (device/'restored').is_file() and (device/'manual.reaped').is_file() and base['locks_absent']
        expected_sha=(device/'receiver.raw.sha256').read_text().split()[0]
        assert re.fullmatch('[a-f0-9]{64}',expected_sha) and int((device/'receiver.raw.bytes').read_text())==total
        for lock in ['/data/x2v-source-20261012/source-session.lock','/data/x2v-native-20261012/gui-session.lock','/blackbox/x2v-native-20261011/gui-session.lock']:
            assert adb('shell','test ! -e '+lock+' && echo CLEAR').strip()=='CLEAR'
        assert adb('shell','getprop init.svc.camera-service').strip()=='running'
        assert shutil.disk_usage(out).free>=total+FRAME_BYTES+RESERVE_BYTES
        nonce=secrets.token_hex(16)
        final=out/'raw-ring72-3920x2946-stride7936.bin';assert not final.exists()
        host_partial=out/('raw-ring72-'+nonce+'.partial')
        remote='/data/x2v-source-20261012/runs/'+args.run
        bulk='/mnt/media_rw/ssd/x2v-source-20261012/runs/'+args.run+'/raw.partial'
        frames=[]
        # O_EXCL host assembly. Only one frame occupies /data at a time.
        with host_partial.open('xb') as assembled,connect() as factory:
            for frame in contract['frames']:
                index=frame['index'];temp='rb-'+nonce[:8]+'-'+str(index)+'.p';native_temp=remote+'/'+temp
                free_cmd="df -k /data | tail -n 1"
                df=factory.factory_shell(free_cmd,capture_ms=3000)
                fields=df.split();assert len(fields)>=6 and fields[-3].isdigit(),df
                assert int(fields[-3])*1024>=FRAME_BYTES+RESERVE_BYTES
                # Verified toybox flags only. Noclobber creates an exclusive own
                # file; no fullblock/conv=notrunc or zero-padding fallback.
                cmd='cd '+remote+' && (umask 077;set -C;toybox dd if='+bulk+' bs=7936 skip='+str(index*2946)+' count=2946 status=none >'+temp+')'
                assert len(cmd.encode())<=231,(len(cmd.encode()),cmd)
                reply=factory.factory_shell(cmd,capture_ms=6000)
                stat_reply=adb('shell','test -f '+native_temp+' && test ! -L '+native_temp+' && stat -c "%d:%i:%h:%s" '+native_temp).strip()
                dev,ino,nlink,size=stat_reply.split(':');assert nlink=='1' and int(size)==FRAME_BYTES
                chunk_sha=adb('shell','sha256sum '+native_temp).split()[0];assert re.fullmatch('[a-f0-9]{64}',chunk_sha)
                host_frame=out/('rb-'+nonce+'-'+str(index)+'.partial')
                with host_frame.open('xb') as destination:
                    held=os.fstat(destination.fileno());host_identity=(held.st_dev,held.st_ino)
                    transfer=subprocess.run(['adb','-s','123456789ABCDEF','exec-out','cat',native_temp],
                        stdout=destination,stderr=subprocess.PIPE,timeout=45)
                    assert transfer.returncode==0,transfer.stderr.decode(errors='replace')
                    destination.flush();os.fsync(destination.fileno())
                    held=os.fstat(destination.fileno())
                    assert (held.st_dev,held.st_ino)==host_identity
                assert (host_frame.stat().st_dev,host_frame.stat().st_ino)==host_identity
                assert host_frame.stat().st_size==FRAME_BYTES and sha_file(host_frame)==chunk_sha
                with host_frame.open('rb') as chunk:
                    while data:=chunk.read(1024*1024):assembled.write(data)
                # Only confirmed same-inode, own complete temp is removed.
                cleanup='test ! -L '+native_temp+' && test "$(stat -c "%d:%i:%h:%s" '+native_temp+')" = '+stat_reply+' && rm '+native_temp
                adb('shell',cleanup)
                host_frame.unlink();host_frame=None;native_temp=None
                item=dict(frame,sha256=chunk_sha,native_copy_reply=reply);frames.append(item)
            assembled.flush();os.fsync(assembled.fileno())
        assert host_partial.stat().st_size==total and sha_file(host_partial)==expected_sha
        # Atomic no-replace publication, equivalent to exclusive final rename;
        # never replace a prior final or overwrite an unknown partial.
        os.link(host_partial,final);host_partial.unlink();host_partial=None
        result.update(passed=True,raw_bytes=total,raw_sha256=expected_sha,raw_path=str(final),receiver_receipt=rx,
            frames=frames,actual_frames=count,stop_reason=contract['stop_reason'],
            cpu_admission_intervals_ns=contract['cpu_admission_intervals_ns'],
            cpu_write_completion_intervals_ns=contract['cpu_write_completion_intervals_ns'],
            native_timestamp_deltas=contract['native_timestamp_deltas'],native_timestamp_unit='unverified',
            copy_provider=contract['copy_provider'],cpu_copy_wall_ns=contract['cpu_copy_wall_ns'],
            cpu_copy_thread_ns=contract['cpu_copy_thread_ns'],
            cpu_wall_quality_false_frame_indices=contract['cpu_wall_quality_false_frame_indices'],
            capture_success_verified=contract['capture_success_verified'],
            configuration_applied_verified=contract['configuration_applied_verified'],
            expected_mem_flags=contract['expected_mem_flags'],
            temporary_data_chunks_removed=True,native_stop_and_restore=True,
            sensor_exposure_fps_verified=False,continuous_recording_verified=False,field_of_view_verified=False)
        result.update({key:contract[key] for key in (
            'writer_provider','writer_flags_before','writer_flags_active',
            'cpu_write_wall_ns','cpu_write_thread_ns','writer_cpu_wall_quality_false_frame_indices',
            'writer_fsync_wall_ns','writer_fsync_thread_ns','writer_fsync_cpu_wall_consistent',
            'direct_writer_verified')})
    except BaseException as exc:
        # Preserve failed assembly/chunk and native temp; never remove unknown
        # files or conceal a short read. Native source is never modified.
        result.update(failure=repr(exc),retained_host_partial=str(host_partial) if host_partial else None,
            retained_host_chunk=str(host_frame) if host_frame else None,retained_native_temp=native_temp)
    report_path.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(dict(passed=result['passed'],report=str(report_path),failure=result.get('failure')),indent=2))
    return 0 if result['passed'] else 1

if __name__=='__main__':raise SystemExit(main())
