import QtQuick
QtObject {
    id: root
    // codec is what the supervisor records: gui.cmd "profile_<id>", state.json "codec"/"profile_id".
    // H.264: 原厂 set_live_view_extended 大约 30 fps，画面干净，没有接到机内落盘。
    // 机内链路是 MODE21 SOUT1，锁 24 fps，有色带。先灰掉，不可选。
    // ProRes RAW: C24 / C25 / D30 qualified from source timestamps; DNG remains 24.
    readonly property var profiles: [
        {id: "h264_1300_970_24", codec: "h264", raw: false, width: 1300, height: 970, fps: 24, format: "H.264", bitrate: "2.5 MB/s", bits: "", opengate: false, available: false, verifiedLabel: "等待会话"},
        // 约 104 MB/s: previously measured ProRes RAW HQ rate for this frame size.
        // 408 MB/s: 3888×2912, 12-bit, 24 fps.
        {id: "raw_3920_2946_24", codec: "prores_raw", raw: true, width: 3888, height: 2912, fps: 24, format: "ProRes RAW HQ", bitrate: "约 104 MB/s", bits: "", opengate: true, available: true, verifiedLabel: "等待会话"},
        {id: "raw_3920_2946_25", codec: "prores_raw", raw: true, width: 3888, height: 2912, fps: 25, format: "ProRes RAW HQ", bitrate: "随画面变化", bits: "", opengate: true, available: true, verifiedLabel: "切换中"},
        {id: "raw_3920_2946_30", codec: "prores_raw", raw: true, width: 3888, height: 2912, fps: 30, format: "ProRes RAW HQ", bitrate: "实验性 · 可能掉帧", bits: "", opengate: true, available: true, verifiedLabel: "切换中"},
        {id: "dng_3888_2912_24", codec: "dng", raw: true, width: 3888, height: 2912, fps: 24, format: "CinemaDNG", bitrate: "408 MB/s", bits: "12-bit", opengate: true, available: true, verifiedLabel: "等待会话"}
    ]
    property string selectedProfileId: "raw_3920_2946_24"
    property string backendProfileId: ""
    property bool backendReady: false
    property bool busy: false
    property int durationSeconds: 300
    readonly property string durationLabel: durationSeconds === 0 ? "永不" : (durationSeconds / 60) + " 分钟"
    signal durationSelected(int seconds)
    function selectDuration(seconds) {
        if (busy || !Number.isInteger(seconds) || (seconds !== 0 && (seconds < 60 || seconds > 1800 || seconds % 60 !== 0))) return false;
        durationSelected(seconds);
        return true;
    }
    readonly property var selected: find(selectedProfileId) || find("raw_3920_2946_24")
    readonly property bool selectionValid: selectedProfileId === selected.id
    readonly property bool canRecord: selectionValid && backendReady && backendProfileId === selectedProfileId && !busy
    readonly property string note: selected ? selected.bitrate : ""
    readonly property string driveLine: !selected ? ""
        : selected.width + " × " + selected.height + " · " + selected.format + " · " + selected.fps + " fps"
          + (selected.opengate ? " · OPENGATE" : "")
          + (selected.bits ? " · " + selected.bits : "")
          + (selected.bitrate ? " · " + selected.bitrate : "")
          + (canRecord ? "" : " · " + selected.verifiedLabel)
    signal intentSelected(string profileId)
    function find(id) {
        for (var i = 0; i < profiles.length; ++i)
            if (profiles[i].id === id) return profiles[i];
        return null;
    }
    function formats() {
        var seen = {}, out = [];
        for (var i = 0; i < profiles.length; ++i) {
            var f = profiles[i].format;
            if (seen[f]) continue;
            seen[f] = true;
            out.push(profiles[i]);
        }
        return out;
    }
    function fpsList(format) {
        var out = [];
        for (var i = 0; i < profiles.length; ++i)
            if (profiles[i].format === format) out.push(profiles[i]);
        return out;
    }
    function select(id) {
        var p = find(id);
        if (busy || !p || p.available === false) return false;
        if (id !== selectedProfileId) {
            selectedProfileId = id;
            intentSelected(id);
        }
        return true;
    }
    function selectFormat(format) {
        var fps = selected ? selected.fps : 24, match = null, first = null;
        for (var i = 0; i < profiles.length; ++i) {
            if (profiles[i].format !== format || profiles[i].available === false) continue;
            if (!first) first = profiles[i];
            if (profiles[i].fps === fps) { match = profiles[i]; break; }
        }
        if (!match && !first) return false;
        return select((match || first).id);
    }
    function selectFps(fps) {
        var format = selected ? selected.format : "";
        for (var i = 0; i < profiles.length; ++i)
            if (profiles[i].format === format && profiles[i].fps === fps)
                return select(profiles[i].id);
        return false;
    }
    function setRaw(value) {
        if (selected.raw === value) return true;
        var fps = selected.fps, match = null, first = null;
        for (var i = 0; i < profiles.length; ++i) {
            if (profiles[i].raw !== value || profiles[i].available === false) continue;
            if (!first) first = profiles[i];
            if (profiles[i].fps === fps) { match = profiles[i]; break; }
        }
        if (!match && !first) return false;
        return select((match || first).id);
    }
}
