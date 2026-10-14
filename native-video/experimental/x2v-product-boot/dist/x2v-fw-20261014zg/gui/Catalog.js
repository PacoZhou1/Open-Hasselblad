.pragma library

// Producer must verify the final file exists before publishing this catalogue.
function localPath(value, roots) {
    if (typeof value !== "string" || value.indexOf("\u0000") >= 0) return "";
    var path = value;
    if (path.indexOf("file://") === 0) {
        try { path = decodeURIComponent(path.substring(7)); } catch (_) { return ""; }
    }
    if (path.charAt(0) !== "/" || /(^|\/)\.\.?($|\/)/.test(path)) return "";
    for (var i = 0; i < roots.length; ++i) {
        var root = String(roots[i]).replace(/\/+$/, "");
        if (root.length > 0 && path.indexOf(root + "/") === 0) return path;
    }
    return "";
}
function fileUrl(path) {
    return "file://" + path.split("/").map(encodeURIComponent).join("/");
}
function normalize(snapshot, roots) {
    if (!snapshot || snapshot.schemaVersion !== 1 || !Array.isArray(snapshot.clips))
        throw new Error("视频目录格式无效");
    var result = [], ids = {}, paths = {};
    for (var i = 0; i < snapshot.clips.length; ++i) {
        var c = snapshot.clips[i];
        if (!c || c.state !== "saved" || c.finalized !== true) continue;
        var path = localPath(c.source, roots), duration = Number(c.duration);
        if (!path || !/\.(mp4|mov)$/i.test(path) || /\.partial(?:\.|$)/i.test(path) ||
            typeof c.id !== "string" || !c.id || ids[c.id] || paths[path] ||
            !isFinite(duration) || duration <= 0 || !isFinite(Number(c.bytes)) || !(Number(c.bytes) > 0)) continue;
        var thumb = localPath(c.thumbnail || "", roots);
        if (thumb && !/\.(png|jpe?g|ppm)$/i.test(thumb)) thumb = "";
        ids[c.id] = true; paths[path] = true;
        result.push({ id: c.id, source: path, sourceUrl: fileUrl(path),
            title: String(c.title || path.substring(path.lastIndexOf("/") + 1)),
            thumbnail: thumb ? fileUrl(thumb) : "", duration: duration,
            width: Number(c.width) || 0, height: Number(c.height) || 0,
            bytes: Number(c.bytes), createdAt: String(c.createdAt || ""),
            format: String(c.format || (/\.mov$/i.test(path) ? "ProRes RAW HQ" : "H.264 / MP4")) });
    }
    return result;
}
function time(seconds) {
    var n = isFinite(seconds) ? Math.max(0, Math.floor(seconds)) : 0;
    return Math.floor(n / 60) + ":" + (n % 60 < 10 ? "0" : "") + n % 60;
}
