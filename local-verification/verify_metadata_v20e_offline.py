"""Focused V20e packet/decoder validation. No camera modules are imported."""
from pathlib import Path
import copy
import hashlib
import json
import struct
import subprocess
from decode_raw_native_metadata_v20e import decode, read_manifest

R=Path(__file__).resolve().parents[1]
P=R/'native-video/experimental/source-session-isolated-two-v20e-metadata'
D=R/'native-video/experimental/source-session-isolated-two-v20d-metadata'
A=R/'research/full-fov-pipeline/raw-banding-calibration-investigation/native-frame-metadata-audit/rx18-callback-candidate'


def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()


def patched(row,offset,fmt,value):
    out=copy.deepcopy(row);b=bytearray.fromhex(row['native_metadata_hex_v1'])
    struct.pack_into(fmt,b,offset,value);out['native_metadata_hex_v1']=b.hex();return out


def rejected(row):
    try:decode(row)
    except ValueError:return True
    raise AssertionError('invalid metadata was accepted')


def main():
    freeze=json.loads((P/'freeze.json').read_text())
    # Root may have consumed the delivered packet before this independent check.
    # Validate its flags without altering the packet or any shared hold state.
    assert bool(freeze['hard_hold']) != bool(freeze['execution_approved'])
    for name,digest in freeze['runtime_files'].items():assert sha(P/name)==digest
    for name in ['controller.sh','bootstrap.sh','guard.sh']:
        subprocess.run(['/bin/sh','-n',str(P/name)],check=True)
    for name in ['prepare_metadata_v20e_packet.py','source_metadata_v20e_stage.py',
                 'run_metadata_v20e_once.py','isolated_two_v20e_metadata_test.py',
                 'decode_raw_native_metadata_v20e.py']:
        compile((R/'local-verification'/name).read_text(),name,'exec')
    old=json.loads((D/'freeze.json').read_text())
    expected=(D/'controller.sh').read_text().replace(old['mode'],freeze['mode'])
    expected=expected.replace(old['receiver_path'],freeze['receiver_path']).replace(old['receiver_sha256'],freeze['receiver_sha256'])
    assert expected==(P/'controller.sh').read_text()
    assert sha(P/'imx861bqr_hb722.sp')==sha(D/'imx861bqr_hb722.sp')
    assert sha(P/'imx861bqr_hb722.conf')==sha(D/'imx861bqr_hb722.conf')
    host=json.loads((A/'host-verification.json').read_text())
    case=Path(host['cases'][0]['output'])
    manifest=next(case.rglob('segment.jsonl'))
    row=next(json.loads(line) for line in manifest.read_text().splitlines() if '"index"' in line)
    read1=decode(row);assert read1['container_permission']==1 and read1['metadata_state']=='read'
    permission3=patched(row,52,'<I',3);read3=decode(permission3)
    assert read3['fields']==read1['fields'] and read3['container_permission']==3
    # The scalar payload is from actual C fixtures; changing only the permission
    # header is a wire-policy unit check, not an E physical-frame claim.
    bad_fid=copy.deepcopy(permission3);bad_fid['source_id']+=1
    rejects=dict(wrong_sourceID=rejected(bad_fid),
        exact_match_assertion=rejected(patched(permission3,58,'<B',1)),
        writer_active=rejected(patched(permission3,56,'<H',1)),
        noREAD0=rejected(patched(permission3,52,'<I',0)),
        write_only2=rejected(patched(permission3,52,'<I',2)),
        unknown_enum5=rejected(patched(permission3,52,'<I',5)))
    d=R/'native-video/outputs/source-isolated-214208/device-run'
    states=[]
    for name in ['dng.metadata.jsonl','dng2.metadata.jsonl']:
        report=read_manifest(d/name);states.append(dict(frames=report['frame_count'],states=report['metadata_states']))
        assert report['metadata_states']['not_read_only']==report['frame_count']
    report=dict(passed=True,device_access=False,held_packet=bool(freeze['hard_hold']),
        root_packet_release_observed=bool(freeze['execution_approved']),
        shell_syntax_and_python_compile=True,controller_only_mode_path_hash_changes=True,
        SP_conf_D_byte_identical=True,decoder_accepts_READ_permissions=[1,3],
        writer_count_required=0,wire_rejections=rejects,
        decoder_fixture_scope='Actual C typed payload + synthetic permission-only wire variation; actual E C policy tested separately.',
        D125skip_records_remain_unavailable=states,exact_exposure_frame_match_proven=0)
    (P/'offline-verification.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report))


if __name__=='__main__':main()
