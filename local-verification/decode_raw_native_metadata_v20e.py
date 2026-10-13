"""Decode CPU-owned XMD1 records without opening or changing RAW pixels.

Native exposure history may fall back to an earlier value. These are frame-bound
metadata observations, not sensor-register or exact exposure-match proof.
"""
import argparse
import json
import math
import struct
from pathlib import Path

FIELDS = [
    (0x3EA, "video_shutter_seconds", 6, 1, 1),
    (0x3EB, "still_shutter_seconds", 6, 1, 1),
    (0x3EE, "video_iso", 4, 1, 1),
    (0x3EF, "still_iso", 4, 1, 1),
    (0x41C, "still_sensor_analog_gain_raw", 5, 1, 1),
    (0x41D, "video_sensor_analog_gain_raw", 5, 1, 1),
    (0x41E, "still_sensor_digital_gain_raw", 5, 1, 1),
    (0x41F, "video_sensor_digital_gain_raw", 5, 1, 1),
    (0x423, "still_isp_digital_gain_raw", 5, 1, 1),
    (0x4C3, "black_level_dng_tag", 5, 1, 4),
    (0x50C, "bit_depth_status", 2, 1, 1),
    (0x5A6, "sensor_shutter_mode_raw", 4, 1, 1),
    (0x5BB, "sensor_mode_prefix_raw", 1, 4, 4096),
]
STATES = ["read", "bad_contract", "no_container", "no_read_permission",
          "active_writer", "not_read_only"]
FIELD_STATES = ["absent", "copied", "shape_mismatch", "null_data"]


def decode(row):
    encoded = row["native_metadata_hex_v1"]
    if not isinstance(encoded, str) or len(encoded) != 1056:
        raise ValueError("XMD1 must contain exactly 528 bytes")
    data = bytes.fromhex(encoded)
    header = struct.unpack_from("<4sHHIIQQIIQI I HBB", data)
    magic, version, count, size, reserved, clip, slot, index, fid, stamp, state, permission, writers, exact, tail = header
    if (magic, version, count, size, reserved, exact, tail) != (b"XMD1", 1, 13, 528, 0, 0, 0):
        raise ValueError("unsupported XMD1 header or unproven exact-match assertion")
    if not clip or not slot or index >= 240 or not fid or not stamp or state >= len(STATES):
        raise ValueError("invalid XMD1 identity/state")
    if (index, fid, stamp) != (row["index"], row["source_id"], row["native_timestamp_raw"]):
        raise ValueError("metadata identity does not match RAW frame")
    if row["file"] != f"frame-{index:06d}.dng":
        raise ValueError("RAW filename/index mismatch")
    if state == 0 and (permission not in (1, 3) or writers != 0):
        raise ValueError("read state contradicts READ-capability/writer0 guard")
    result = dict(index=index, file=row["file"], source_id=fid,
                  native_timestamp_raw=stamp, clip_generation=clip,
                  slot_generation=slot, metadata_state=STATES[state],
                  container_permission=permission, observed_writer_count=writers,
                  exact_exposure_frame_match_proven=False, fields={})
    for n, (tag, name, expected_type, low, high) in enumerate(FIELDS):
        actual_tag, field_state, native_type, native_count, copied, raw = struct.unpack_from("<IIiiI16s", data, 60 + 36*n)
        if actual_tag != tag or field_state >= len(FIELD_STATES) or copied > 16:
            raise ValueError(f"invalid field shape: {name}")
        value = dict(state=FIELD_STATES[field_state], native_type=native_type,
                     native_count=native_count, bytes_hex=raw[:copied].hex())
        if field_state != 1:
            if copied or any(raw):
                raise ValueError(f"invalid bytes for unavailable field: {name}")
        else:
            if state != 0 or native_type != expected_type or not low <= native_count <= high:
                raise ValueError(f"copied field violates native contract: {name}")
            width, code = {1: (1, "B"), 2: (2, "H"), 4: (4, "I"), 5: (4, "i"), 6: (4, "f")}[native_type]
            expected_bytes = 4 if tag == 0x5BB else native_count * width
            if copied != expected_bytes or any(raw[copied:]):
                raise ValueError(f"copied field byte count/padding mismatch: {name}")
            values = list(struct.unpack("<" + code * (copied // width), raw[:copied]))
            if native_type == 6 and not all(math.isfinite(v) for v in values):
                value["numeric_status"] = "nonfinite_native_value"
            else:
                value["value"] = values[0] if len(values) == 1 else values
        result["fields"][name] = value
    return result


def read_manifest(path):
    frames = []
    for line in path.read_text().splitlines():
        row = json.loads(line)
        if "index" in row:
            frame = decode(row)
            if frame["index"] != len(frames):
                raise ValueError("sequence indices are not contiguous")
            if frames and (frame["clip_generation"] != frames[0]["clip_generation"] or
                           frame["source_id"] <= frames[-1]["source_id"] or
                           frame["native_timestamp_raw"] <= frames[-1]["native_timestamp_raw"]):
                raise ValueError("mixed clip or nonmonotonic source frame identity")
            frames.append(frame)
    if not frames:
        raise ValueError("manifest contains no XMD1 frames")
    return dict(manifest=str(path.resolve()), scope="native metadata observations only",
                exact_exposure_frame_match_proven=False, frame_count=len(frames),
                metadata_states={s: sum(f["metadata_state"] == s for f in frames) for s in STATES},
                frames=frames)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("manifest", type=Path)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    report = read_manifest(args.manifest)
    output = json.dumps(report, indent=2, allow_nan=False) + "\n"
    if args.output:
        with args.output.open("x") as file:
            file.write(output)
        print(json.dumps({"output": str(args.output), "frames": report["frame_count"],
                          "metadata_states": report["metadata_states"]}))
    else:
        print(output, end="")
