import QtQuick

// Firmware candidate: a bounded touch region over the monitor. The owner must
// provide current histogram samples and separately validated RGB clipping data.
Item {
    id: root
    objectName: "exposureAssistOverlay"
    property var histogramData: null
    property bool histogramValid: false
    property string histogramAxis: "raw_soft_log2_16"
    property var high: [false, false, false]
    property var low: [false, false, false]
    property bool rawStatsValid: false
    property bool rawHighValid: rawStatsValid
    property bool rawLowValid: rawStatsValid
    property bool interactionAllowed: true
    property var avoidRects: []
    readonly property real inset: 16
    readonly property real topInset: 80
    readonly property real bottomInset: 112
    property bool initialized: false
    property bool placementValid: true
    property alias panelX: panel.x
    property alias panelY: panel.y
    signal moved(real x, real y)

    function limit(value, lo, hi) { return Math.max(lo, Math.min(value, hi)); }
    function xMax() { return Math.max(inset, width - inset - panel.width); }
    function yMax() { return Math.max(topInset, height - bottomInset - panel.height); }
    function initialize() {
        if (initialized || width < panel.width + 2*inset || height < topInset + bottomInset + panel.height) return;
        panel.x = inset + 8;
        panel.y = yMax() - 12;
        initialized = true;
        settle();
    }
    function overlaps(x, y, rect) {
        return x < rect.x + rect.width && x + panel.width > rect.x &&
               y < rect.y + rect.height && y + panel.height > rect.y;
    }
    function validAt(x, y) {
        if (x < inset || x > xMax() || y < topInset || y > yMax()) return false;
        for (var i=0; i<avoidRects.length; ++i) {
            var r=avoidRects[i];
            if (r && r.width > 0 && r.height > 0 && overlaps(x,y,r)) return false;
        }
        return true;
    }
    function settle() {
        if (!initialized || dragArea.drag.active) return;
        var x=limit(panel.x,inset,xMax()), y=limit(panel.y,topInset,yMax());
        if (validAt(x,y)) { panel.x=x; panel.y=y; placementValid=true; return; }
        var xs=[x,inset,xMax()], ys=[y,topInset,yMax()];
        for (var i=0;i<avoidRects.length;i++) {
            var r=avoidRects[i]; if (!r || r.width<=0 || r.height<=0) continue;
            xs.push(limit(r.x-panel.width-8,inset,xMax()), limit(r.x+r.width+8,inset,xMax()));
            ys.push(limit(r.y-panel.height-8,topInset,yMax()), limit(r.y+r.height+8,topInset,yMax()));
        }
        var best=null, bestD=Infinity;
        for (var j=0;j<xs.length;j++) for (var k=0;k<ys.length;k++) {
            var xx=xs[j], yy=ys[k]; if (!validAt(xx,yy)) continue;
            var d=(xx-x)*(xx-x)+(yy-y)*(yy-y);
            if (d<bestD) { best={x:xx,y:yy}; bestD=d; }
        }
        placementValid=!!best;
        if (best) { panel.x=best.x; panel.y=best.y; }
    }
    onWidthChanged: { initialize(); if (initialized) reposition.restart(); }
    onHeightChanged: { initialize(); if (initialized) reposition.restart(); }
    onAvoidRectsChanged: if (initialized && !reposition.running) reposition.start()
    onVisibleChanged: if (visible) { initialize(); reposition.restart(); }
    Component.onCompleted: initialize()
    Timer { id: reposition; interval: 50; repeat: false; onTriggered: root.settle() }

    Rectangle {
        id: panel
        objectName: "exposureAssistPanel"
        width:224; height:80; visible:root.placementValid
        color:"#C81A1A1A"; radius:5; border.color:"#4FFFFFFF"; border.width:1
        Canvas {
            id: graph
            objectName:"demoHistogram"
            x:32; y:8; width:160; height:51
            function readValues() {
                var d=root.histogramData;
                if (d===null || d===undefined) return [];
                if (typeof d.length === "number" && d.length > 0) return d;
                try { return new Uint8Array(d); } catch(e) { return []; }
            }
            onPaint: {
                var c=getContext("2d"); c.reset();
                c.fillStyle="#38000000"; c.fillRect(0,0,width,height);
                c.strokeStyle="#22FFFFFF"; c.lineWidth=1; c.beginPath();
                for (var mark=1;mark<4;mark++) {
                    var gx=Math.round(width*mark/4)+0.5;
                    c.moveTo(gx,2); c.lineTo(gx,height-1);
                }
                c.stroke();
                c.strokeStyle="#60FFFFFF"; c.lineWidth=1; c.beginPath();
                c.moveTo(0,height-0.5); c.lineTo(width,height-0.5); c.stroke();
                var samples=readValues(), n=samples.length;
                if (!root.histogramValid || !n) return;
                var scale=(n===256) ? 255.0 : 1.0;
                c.beginPath(); c.moveTo(0,height-2);
                for (var x=0;x<width;x++) {
                    var begin=Math.floor(x*n/width), end=Math.max(begin+1,Math.floor((x+1)*n/width)), peak=0;
                    for (var k=begin;k<end && k<n;k++) peak=Math.max(peak,Number(samples[k]) || 0);
                    c.lineTo(x,height-3-Math.min(1,peak/scale)*(height-8));
                }
                c.lineTo(width,height-2); c.closePath(); c.fillStyle="#DFEAEAEA"; c.fill();
            }
            Connections {
                target:root
                function onHistogramDataChanged() { graph.requestPaint() }
                function onHistogramValidChanged() { graph.requestPaint() }
                function onHistogramAxisChanged() { graph.requestPaint() }
                function onVisibleChanged() { graph.requestPaint() }
            }
        }
        Text { x:32; y:61; text:"RAW · Log"; color:"#C5C5C5"; font.pixelSize:10 }
        Text { x:164; y:61; text:"100%"; color:"#C5C5C5"; font.pixelSize:10 }
        Text { anchors.centerIn:graph; visible:!root.histogramValid; text:"—"; color:"#B6B6B6"; font.pixelSize:22 }
        Column {
            x:13; y:16; spacing:6
            Repeater {
                model:3
                Rectangle {
                    required property int index
                    objectName:"shadowLight"+index
                    property var channelColors:["#FF5B5B","#66DB96","#75AEFF"]
                    property bool active:root.rawLowValid && root.low && root.low[index]
                    width:12; height:12; radius:6
                    color:active ? channelColors[index] : root.rawLowValid ? "#565656" : "transparent"
                    border.color:active ? channelColors[index] : "#858585"; border.width:1
                }
            }
        }
        Column {
            x:199; y:16; spacing:6
            Repeater {
                model:3
                Rectangle {
                    required property int index
                    objectName:"highlightLight"+index
                    property var channelColors:["#FF5B5B","#66DB96","#75AEFF"]
                    property bool active:root.rawHighValid && root.high && root.high[index]
                    width:12; height:12; radius:6
                    color:active ? channelColors[index] : root.rawHighValid ? "#565656" : "transparent"
                    border.color:active ? channelColors[index] : "#858585"; border.width:1
                }
            }
        }
        MouseArea {
            id:dragArea
            objectName:"exposureAssistDrag"
            anchors.fill:parent
            enabled:root.interactionAllowed
            preventStealing:true
            pressAndHoldInterval:400
            property bool dragInitiated:false
            onPressAndHold:dragInitiated=true
            onReleased: { dragInitiated=false; reposition.restart(); root.moved(panel.x,panel.y); }
            onCanceled: { dragInitiated=false; reposition.restart(); }
            drag.target:dragInitiated ? panel : null
            drag.axis:Drag.XAndYAxis
            drag.threshold:16
            drag.minimumX:root.inset
            drag.maximumX:root.xMax()
            drag.minimumY:root.topInset
            drag.maximumY:root.yMax()
        }
    }
}
