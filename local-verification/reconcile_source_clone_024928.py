"""Offline reconciliation of the preserved first clone run's log-parser failure."""
import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RUN = ROOT/'native-video/outputs/source-clone-024928'
original = json.loads((RUN/'report.json').read_text())
log = (RUN/'device-run/manual-service.log').read_text(errors='replace')
events = (RUN/'device-run/events.log').read_text()
clone = re.findall(r'X2V_SOURCE_ADAPTER clone_ready build=normal-clone-v1 load_bias=0x[0-9a-f]+ dladdr_mapping=0x[0-9a-f]+ descriptor_bytes=192 mode_count=24 hb_index=23 driver_index=52 calls=[1-8] hardware_owner=native_init frame_evidence=false', log)
init = re.findall(r'X2V_SOURCE_ADAPTER native_init_end rc=0 clone_retained_until_exit=true', log)
rejects = re.findall(r'X2V_SOURCE_ADAPTER (?:reject=\S+|native_init_end rc=-?[1-9][0-9]*)', log)
frames = [list(map(int, x)) for x in re.findall(r'FRAMES first=(\d+) last=(\d+)', events)]
assert len(clone) == len(init) == 1 and not rejects
assert frames == [[470, 620], [477, 627]]
assert original['body_rc'] == '5' and original['recovery_rc'] == '0'
assert original['locks_absent'] and original['after']['processes'].splitlines()[2:] == ['running', 'running']
assert '(ro,' in original['after']['system_mount']
assert 'NORMAL_STOCK_RESTORED' in events
assert 'proc_state=Z raw_start=3286437' in events
assert 'PARENT_REAP_END pid=15044 wait_rc=1 proc_state=\n' in events
result = {
    'original_report_retained': True,
    'original_runner_passed': original['passed'],
    'failure': 'Strict line anchors rejected vendor-prefixed/interleaved adapter messages; body exited 5.',
    'native_factory_and_owned_descriptor_init_verified': True,
    'clone_messages': clone + init,
    'rejection_messages': rejects,
    'normal_manual_frames': frames[0],
    'normal_restored_frames': frames[1],
    'first_recovery_rc': 0,
    'parent_observed_zombie_then_reaped': True,
    'old_stock_run_zombie_cause_proven': False,
    'physical_user_acceptance': 'not collected for this run',
    'new_high_resolution_mode_verified': False,
    'after': original['after'],
    'locks_absent': True,
    'files': {str(p.relative_to(RUN)): hashlib.sha256(p.read_bytes()).hexdigest()
              for p in [RUN/'report.json', RUN/'device-run/events.log', RUN/'device-run/manual-service.log']},
}
(RUN/'reconciled.json').write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps({'native_clone_verified': True, 'first_recovery_rc': 0,
                  'evidence': str(RUN/'reconciled.json')}, indent=2))
