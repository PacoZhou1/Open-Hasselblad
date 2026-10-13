"""Grok-raw30 delivery vs 30fps period; does not mutate frozen dng_async_metrics."""
from dng_async_metrics import measure as async_measure

def measure(rx, manifest):
    result = async_measure(rx, manifest)
    fps = result['delivered_fps']
    contiguous = result['source_ids_contiguous']
    drops = result['receiver_drops']
    warm = result['warm_put_ms']['median']
    result['short_trial_30fps_delivery_pass'] = bool(contiguous and drops == 0 and 29.70 <= fps <= 30.30)
    result['sustained_30fps_verified'] = bool(result['short_trial_30fps_delivery_pass'] and warm < 33.333)
    return result
