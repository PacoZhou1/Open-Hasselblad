"""Offline u16 container inspection of a verified direct RAW readback.

Run with the bundled workspace Python (numpy and Pillow). The preview is a
contrast-stretched diagnostic, not a demosaic or proof of CFA/bit depth/FOV.
"""
import argparse
import hashlib
import json
from pathlib import Path

import numpy as np
from PIL import Image


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("readback_report", type=Path)
    args = ap.parse_args()
    report_path = args.readback_report.resolve()
    report = json.loads(report_path.read_text())
    assert report["passed"] and report["session_passed"]
    receipt = report["receiver_receipt"]
    assert receipt["state"] == 5 and receipt["frame_id"] > 0
    assert receipt["expected_pixel"] == 10001
    assert receipt["cpu_drained"] == 1 and receipt["drain_rc"] == 0
    assert receipt["rejected"] == 0
    samples = receipt["samples"]
    assert samples and all(sample == samples[0] for sample in samples)
    shape = samples[0]
    width, height, stride = (shape[key] for key in ("width", "height", "stride"))
    assert shape["pixel_28"] == 10001 and shape["offset"] == 0
    assert shape["planes"] == 1 and shape["planeheight"] == height
    assert stride % 2 == 0 and width * 2 <= stride
    raw_path = Path(report["raw_path"])
    raw = raw_path.read_bytes()
    assert len(raw) == height * stride == report["raw_bytes"]
    digest = hashlib.sha256(raw).hexdigest()
    assert digest == report["raw_sha256"]
    pixels = np.frombuffer(raw, dtype="<u2").reshape(height, stride // 2)[:, :width]
    percentiles = np.percentile(pixels, [0, 1, 50, 99.9, 100])
    low, high = percentiles[1], percentiles[3]
    contrast = np.clip((pixels.astype(np.float32) - low) / max(high - low, 1), 0, 1)
    preview = Image.fromarray(np.round(contrast ** 0.45 * 255).astype("uint8"))
    preview.thumbnail((1600, 1200))
    out = report_path.parent / "container-analysis"
    out.mkdir(exist_ok=False)
    preview.save(out / "preview.png")
    bands = []
    for index, band in enumerate(np.array_split(pixels, 3, axis=0)):
        bands.append({"third": index + 1, "rows": len(band),
                      "mean": float(band.mean()), "std": float(band.std()),
                      "min": int(band.min()), "max": int(band.max())})
    result = {
        "scope": "Unsigned16 little-endian container diagnostic only; not CFA, demosaic, effective-bitdepth or field-of-view proof",
        "readback_report": str(report_path), "raw_sha256": digest,
        "frame_id": receipt["frame_id"], "timestamp_native": receipt["timestamp_native"],
        "descriptor": shape, "row_padding_bytes": stride - width * 2,
        "percentile_levels": [0, 1, 50, 99.9, 100],
        "percentile_values": percentiles.tolist(),
        "unique_values": int(np.unique(pixels).size),
        "low_bits_nonzero_words": {str(bits): int(np.count_nonzero(pixels & ((1 << bits) - 1))) for bits in range(1, 9)},
        "row_bands": bands, "preview": str(out / "preview.png"),
        "preview_transform": "Percentiles1..99.9 clipped, gamma0.45; padding excluded, aspect preserved; no crop/demosaic",
    }
    (out / "report.json").write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
