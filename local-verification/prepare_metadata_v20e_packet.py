"""Derive a private offline V20e packet from the successful D graph/stop packet."""
import argparse
import hashlib
import json
import shutil
import subprocess
from pathlib import Path

R=Path(__file__).resolve().parents[1]
OLD=R/'native-video/experimental/source-session-isolated-two-v20d-metadata'
NEW=R/'native-video/experimental/source-session-isolated-two-v20e-metadata'
MODE='isolated-two-v20e-metadata'
DEVICE='/system/lib64/libx2v_mode21c24_metadata_20261012e.so'
EXPECTED='c0f5e72ab9a8deb34595a15c305dfebd25bb75bc423a5e8a37f60086e1c7ecdb'
ARTIFACT=R/'research/full-fov-pipeline/raw-banding-calibration-investigation/native-frame-metadata-audit/rx18-callback-candidate-e/build/target-token/libx2v_rx18_native_metadata_candidate_e_arm.TOKEN_REQUIRED.so'


def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()


def once(text,old,new):
    assert text.count(old)==1,old
    return text.replace(old,new)


def new_file(path,text):
    assert not path.exists(),str(path)
    path.write_text(text)


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('artifact',type=Path,nargs='?',default=ARTIFACT)
    args=parser.parse_args();artifact=args.artifact.resolve()
    assert sha(artifact)==EXPECTED and artifact.stat().st_size==343864
    assert not NEW.exists()
    parent=json.loads((OLD/'freeze.json').read_text())
    before={n:sha(OLD/n) for n in parent['runtime_files']}
    assert before==parent['runtime_files']
    assert parent['boot_id']=='41867eda-01a6-4809-b1d0-ebedba61dce4'
    assert parent['bound_group']=='/uid_0/pid_3102'
    NEW.mkdir()
    for name in before:shutil.copy2(OLD/name,NEW/name)
    control=(NEW/'controller.sh').read_text().replace(parent['mode'],MODE)
    control=once(control,parent['receiver_path'],DEVICE)
    control=once(control,parent['receiver_sha256'],EXPECTED)
    (NEW/'controller.sh').write_text(control)
    bootstrap=(NEW/'bootstrap.sh').read_text().replace(parent['mode'],MODE)
    bootstrap=once(bootstrap,before['controller.sh'],sha(NEW/'controller.sh'))
    (NEW/'bootstrap.sh').write_text(bootstrap)
    guard=(NEW/'guard.sh').read_text().replace(parent['mode'],MODE)
    (NEW/'guard.sh').write_text(guard)
    for name in ('controller.sh','bootstrap.sh','guard.sh'):
        subprocess.run(['/bin/sh','-n',str(NEW/name)],check=True)
    # XMD1 shape and original D lifecycle are byte-identical after substitutions.
    assert (OLD/'controller.sh').read_text().replace(parent['mode'],MODE).replace(parent['receiver_path'],DEVICE).replace(parent['receiver_sha256'],EXPECTED)==control
    assert 'pairs($0,row)!=12' in control and '1058' in control
    freeze=dict(parent)
    freeze.update(mode=MODE,execution_approved=False,hard_hold=True,
        receiver_path=DEVICE,receiver_sha256=EXPECTED,
        parent_freeze_sha256=sha(OLD/'freeze.json'),runtime_files={n:sha(NEW/n) for n in before},
        metadata_allowed_permissions=[1,3],metadata_writer_count_required=0,
        exact_exposure_frame_match_proven=0,
        integrations_pending=['root stage/review/once execution after RX23','actual native metadata tag presence'],
        scope='D graph and stop retained; E metadata READ capability1/3; one two-clip RAW+ISP diagnostic, no encoder',
        prepared_condition={'lens_cap':'removed_user_confirmed','scene':'user_confirmed_uniform_wall',
                            'exposure_controlled':False,'purpose':'E native metadata presence and wall baseline'})
    freeze.pop('root_review',None);freeze.pop('condition',None)
    (NEW/'freeze.json').write_text(json.dumps(freeze,indent=2)+'\n')
    runner=(R/'local-verification/isolated_two_v20d_metadata_test.py').read_text()
    runner=runner.replace('source-session-isolated-two-v20d-metadata',NEW.name).replace(parent['mode'],MODE)
    runner=once(runner,'from decode_raw_native_metadata import read_manifest',
                       'from decode_raw_native_metadata_v20e import read_manifest')
    runner_path=R/'local-verification/isolated_two_v20e_metadata_test.py'
    compile(runner,str(runner_path),'exec');new_file(runner_path,runner)
    stage=(R/'local-verification/source_metadata_v20d_stage.py').read_text()
    stage=stage.replace('rx18-callback-candidate-d','rx18-callback-candidate-e')
    stage=stage.replace('libx2v_rx18_native_metadata_candidate_arm.TOKEN_REQUIRED.so',
                        'libx2v_rx18_native_metadata_candidate_e_arm.TOKEN_REQUIRED.so')
    stage=stage.replace(parent['receiver_sha256'],EXPECTED).replace(parent['receiver_path'],DEVICE)
    stage=stage.replace('source-metadata-v20d-stage','source-metadata-v20e-stage')
    stage_path=R/'local-verification/source_metadata_v20e_stage.py'
    compile(stage,str(stage_path),'exec');new_file(stage_path,stage)
    wrapper=(R/'local-verification/run_metadata_v20d_once.py').read_text()
    wrapper=wrapper.replace('V20d','V20e').replace('v20d','v20e')
    wrapper=wrapper.replace('Getter provider and borrowed permission guard reviewed;',
        'Getter provider, native permission1/3 capability and writer0 guard reviewed;')
    wrapper=wrapper.replace('Actual C lifetime15frames and independent hostdecoder passed;',
        'E actual C sampler/record ASAN/UBSAN focused checks and independent decoder passed; inherited A lifecycle15frames is separate;')
    wrapper_path=R/'local-verification/run_metadata_v20e_once.py'
    compile(wrapper,str(wrapper_path),'exec');new_file(wrapper_path,wrapper)
    assert {n:sha(OLD/n) for n in before}==before
    report=dict(offline=True,device_access=False,parent_D_unchanged=True,packet=str(NEW),held=True,
        boot_id=freeze['boot_id'],bound_group=freeze['bound_group'],receiver_sha256=EXPECTED,
        receiver_device_path=DEVICE,runtime_sha256=freeze['runtime_files'],
        wrapper=str(wrapper_path),stage=str(stage_path),runner=str(runner_path),
        shared_hold_modified=False,shared_handoff_modified=False,
        execution_scope='Root stages and executes after RX23 retires; wrapper retains D release/consume/revoke protocol.')
    (NEW/'offline-preparation.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report,ensure_ascii=False))


if __name__=='__main__':main()
