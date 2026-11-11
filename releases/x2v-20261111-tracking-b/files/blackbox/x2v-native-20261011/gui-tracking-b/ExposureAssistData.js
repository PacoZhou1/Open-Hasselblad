.pragma library

// Change only the display axis. Redistribute bin mass by overlap in the
// original linear domain, rather than stretching a normalized curve or taking
// maxima. The source remains quantized to 256 bins; no new RAW precision is
// implied. RAW clipping decisions below never use this display transform.
function softLogBins(linear) {
    var n=linear.length, result=[], peak=0, k=15, logRange=Math.log(1+k);
    for (var j=0;j<n;j++) {
        var lo=(Math.exp(logRange*j/n)-1)/k;
        var hi=(Math.exp(logRange*(j+1)/n)-1)/k;
        var start=Math.max(0,Math.floor(lo*n));
        var end=Math.min(n-1,Math.ceil(hi*n)-1), mass=0;
        for (var i=start;i<=end;i++) {
            var overlap=Math.max(0,Math.min(hi,(i+1)/n)-Math.max(lo,i/n));
            mass+=Number(linear[i])*overlap*n;
        }
        result.push(mass);
        peak=Math.max(peak,mass);
    }
    return {mass:result, peak:peak, axis:"raw_soft_log2_16"};
}

function displayHistogram(linear) {
    var b=softLogBins(linear), out=[];
    for (var i=0;i<b.mass.length;i++) out.push(b.peak>0 ? Math.min(255,255*(b.mass[i]/b.peak)) : 0);
    return out;
}

function decode(raw, now) {
    var no = {valid:false, highValid:false, lowValid:false,
              histogram:[], histogramAxis:"raw_soft_log2_16",
              high:[false,false,false], low:[false,false,false]};
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
            histogram:displayHistogram(raw.histogram), histogramAxis:"raw_soft_log2_16",
            high:high, low:[false,false,false]};
}
