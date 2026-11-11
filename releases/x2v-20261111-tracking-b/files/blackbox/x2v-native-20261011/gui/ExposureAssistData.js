.pragma library

function decode(raw, now) {
    var no = {valid:false, highValid:false, lowValid:false,
              histogram:[], high:[false,false,false], low:[false,false,false]};
    if (!raw || raw.schema !== 1 || raw.stage !== "RAW before WB and display gain") return no;
    if (!(raw.epoch_ms > 0) || Math.abs(now - raw.epoch_ms) > 1500 ||
        !(raw.sequence > 0) || !(raw.source_ts_us > 0)) return no;
    if (!Array.isArray(raw.histogram) || raw.histogram.length !== 256 ||
        !Array.isArray(raw.sample_count) || raw.sample_count.length !== 3 ||
        !Array.isArray(raw.clipped_count) || raw.clipped_count.length !== 3) return no;
    for (var i=0;i<256;i++)
        if (typeof raw.histogram[i] !== "number" || !isFinite(raw.histogram[i]) ||
            raw.histogram[i]<0 || raw.histogram[i]>255) return no;
    var high=[];
    for (var c=0;c<3;c++) {
        var n=raw.sample_count[c], clipped=raw.clipped_count[c];
        if (!(n>0) || !(clipped>=0) || clipped>n) return no;
        // Explicit coverage alarm: isolated hot pixels are not an area alarm.
        high.push(clipped/n >= 0.001);
    }
    return {valid:true, highValid:raw.highlight_valid === true, lowValid:false,
            histogram:raw.histogram, high:high, low:[false,false,false]};
}
