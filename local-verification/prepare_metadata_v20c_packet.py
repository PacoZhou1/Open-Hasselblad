"""Prepare an offline RX18-derived native metadata trial. No device mutation."""
import argparse
import hashlib
import json
import shutil
import subprocess
from pathlib import Path

R = Path(__file__).resolve().parents[1]
OLD = R / "native-video/experimental/source-session-isolated-two-v18-isp"
NEW = R / "native-video/experimental/source-session-isolated-two-v20c-metadata"
MODE = "isolated-two-v20c-metadata"
BOOT = "41867eda-01a6-4809-b1d0-ebedba61dce4"
GROUP = "/uid_0/pid_3102"
DEVICE = "/system/lib64/libx2v_mode21c24_metadata_20261012c.so"
BASE_SHA = "8486fa7ce0b400992358ad92c445ad026a3784703accf2bae8a490ed10b2ff52"


def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def replace_once(text, old, new):
    assert text.count(old) == 1, old
    return text.replace(old, new)


def prepare(artifact):
    assert not NEW.exists(), "Use a new version after a packet has been prepared"
    assert artifact.is_file()
    NEW.mkdir()
    freeze = json.loads((OLD / "freeze.json").read_text())
    for name in freeze["runtime_files"]:
        shutil.copy2(OLD / name, NEW / name)
    controller = (NEW / "controller.sh").read_text()
    controller = controller.replace("isolated-two-v18-isp", MODE).replace("/uid_0/pid_5258", GROUP)
    controller = controller.replace(freeze["receiver_path"], DEVICE).replace(freeze["receiver_sha256"], sha(artifact))
    # Keep RX18 token/RAW geometry/stop/recovery; add one library used by the getter.
    for needle in ['verify_hash "$RECEIPT_VALIDATOR" "$RECEIPT_VALIDATOR_SHA"']:
        assert controller.count(needle) == 2
        controller = controller.replace(needle, f'verify_hash /system/lib64/libdcam_base.so {BASE_SHA} && ' + needle)
    line = next(x for x in controller.splitlines() if x.strip().startswith('frame="^'))
    marker = ',\\"namespace_durable\\":false'
    assert marker in line
    changed = line.replace(marker, marker + ',\\"native_metadata_hex_v1\\":\\"[0-9a-f]+\\"')
    controller = replace_once(controller, line, changed)
    controller = replace_once(controller, 'pairs($0,row)!=11', 'pairs($0,row)!=12')
    needle = '   j=FNR-2;name=sprintf("frame-%06d.dng",j)'
    controller = replace_once(controller, needle,
        '   if(length(row["native_metadata_hex_v1"])!=1058 || substr(row["native_metadata_hex_v1"],2,32)!="584d443101000d001002000000000000")fail()\n' + needle)
    # Save only the small verified manifests beside receipts for host decoding.
    needle = '[ "$(inode_token "$CLIP_DIR/segment.jsonl")" = "$(cat "$RUN/dng$CLIP_SUFFIX.manifest.inode")" ]'
    controller = replace_once(controller, needle + '\n)\n\nselect_clip()', needle + ' &&\n cp "$CLIP_DIR/segment.jsonl" "$RUN/dng$CLIP_SUFFIX.metadata.jsonl"\n)\n\nselect_clip()')
    (NEW / "controller.sh").write_text(controller)
    for name in ["bootstrap.sh", "guard.sh"]:
        text = (NEW / name).read_text().replace("/uid_0/pid_5258", GROUP).replace("isolated-two-v18-isp", MODE)
        if name == "bootstrap.sh":
            text = replace_once(text, freeze["runtime_files"]["controller.sh"], sha(NEW / "controller.sh"))
        (NEW / name).write_text(text)
    for name in ["controller.sh", "bootstrap.sh", "guard.sh"]:
        subprocess.run(["/bin/sh", "-n", str(NEW / name)], check=True)
    freeze.update(mode=MODE, execution_approved=False, hard_hold=True,
                  receiver_path=DEVICE, receiver_sha256=sha(artifact), bound_group=GROUP,
                  boot_id=BOOT, metadata_provider_sha256=BASE_SHA,
                  runtime_files={n: sha(NEW / n) for n in freeze["runtime_files"]},
                  integrations_pending=["root stage/review/release", "native metadata field availability"],
                  scope="RX18 RAW+ISP graph, two bounded captures; native metadata observation only, no encoder; original stop/recovery",
                  parent_freeze_sha256=sha(OLD / "freeze.json"))
    (NEW / "freeze.json").write_text(json.dumps(freeze, indent=2) + "\n")
    runner = (R / "local-verification/isolated_resident_two_v16_dng_test.py").read_text()
    runner = runner.replace("source-session-isolated-resident-two-v16-dng", NEW.name).replace("MODE='isolated-resident-two-v16-dng'", f"MODE='{MODE}'")
    runner = runner.replace("80026cc1-5987-40c7-a271-f68e8165c424", BOOT).replace("/uid_0/pid_5258", GROUP).replace("/acct/uid_0/pid_5258", "/acct" + GROUP)
    needle = "   report['two_clip_oracle_verified']=True"
    runner = replace_once(runner, needle, """   from decode_raw_native_metadata import read_manifest
   report['native_metadata']=[read_manifest(d/name) for name in ['dng.metadata.jsonl','dng2.metadata.jsonl']]
   assert all(m['frame_count']==rx['frames_written'] for m,rx in zip(report['native_metadata'],receipts))
""" + needle)
    output = R / "local-verification/isolated_two_v20c_metadata_test.py"
    assert not output.exists()
    output.write_text(runner)
    compile(runner, str(output), "exec")
    print(json.dumps({"packet": str(NEW), "held": True, "receiver": str(artifact), "runner": str(output)}))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("artifact", type=Path)
    prepare(parser.parse_args().artifact.resolve())
