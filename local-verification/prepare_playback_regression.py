#!/usr/bin/env python3
"""Prepare an offline, explicitly triggered native-player regression package.

This command never connects to the camera. Deploy with gui_session.py only after
review. Start a bounded persistent per-PID logger before writing the run-local
playback-test.json lease. No test timer is added to the product entry point.
"""
import argparse
import json
from pathlib import Path
import shutil
import subprocess
import sys
from types import SimpleNamespace

import gui_session


FRAGMENT = r'''
    AuditControl {
        id: regressionControl
        source: "file:///blackbox/x2v-native-20261011/runs/@RUN@/playback-test.json"
    }
    property int regressionStep: 0
    property int regressionCycles: 0
    property bool regressionDone: false
    property real regressionDeadline: 0
    property real regressionStopAt: 0
    property string regressionLastPhase: ""
    readonly property string regressionClip: "@CLIP@"
    function regressionLog(event, extra) {
        var detail = {event: event, runId: "@RUN@", timestampMs: Date.now(),
                      step: regressionStep, cycles: regressionCycles};
        for (var key in extra) detail[key] = extra[key];
        console.info("X2V_PLAYBACK_REGRESSION " + JSON.stringify(detail));
    }
    function regressionFail(reason) {
        regressionDone = true;
        regressionLog("failed", {reason: reason});
        if (extension.playbackSession.active) extension.playbackSession.stop();
    }
    function regressionOpen() {
        if (!extension.playbackSession.open(regressionClip)) {
            regressionFail("open_rejected"); return false;
        }
        regressionStep = 2;
        return true;
    }
    Timer {
        interval: 100; repeat: true; running: !root.regressionDone
        onTriggered: {
            var p = extension.playbackSession;
            var lease = regressionControl.config;
            var enabled = regressionControl.fresh && lease.enabled === true &&
                          lease.runId === "@RUN@" && lease.loggerReady === true;
            if (root.regressionStep === 0) {
                if (!enabled || !root.regressionBrowseReady()) return;
                if (!httpRecorder.fresh || !httpRecorder.available) {
                    root.regressionFail("bridge_not_ready"); return;
                }
                root.regressionDeadline = Date.now() + 60000;
                root.regressionLog("started", {clipId: root.regressionClip});
                httpRecorder.setVideoMode(true);
                httpRecorder.refreshCatalog();
                root.regressionStep = 1;
                try { root.regressionEnterBrowse(); }
                catch (error) { root.regressionFail("browse_entry:" + error); }
                return;
            }
            if (!enabled) { root.regressionFail("trigger_lease_expired"); return; }
            if (Date.now() > root.regressionDeadline) { root.regressionFail("duration_limit"); return; }
            if (p.phase !== root.regressionLastPhase) {
                root.regressionLastPhase = p.phase;
                root.regressionLog("phase", {phase: p.phase, sessionId: p.sessionId});
            }
            if (p.phase === "error") { root.regressionFail("player_error:" + p.error); return; }
            if (root.regressionStep === 1 && p.catalogReady && extension.stockBrowseActive) {
                var found = p.clips.some(function(clip) { return clip.id === root.regressionClip; });
                if (!found) { root.regressionFail("verified_clip_missing"); return; }
                if (!extension.openGallery()) { root.regressionFail("gallery_open_rejected"); return; }
                root.regressionOpen();
            } else if (root.regressionStep === 2 && p.phase === "idle") {
                root.regressionFail("unexpected_player_release");
            } else if (root.regressionStep === 2 && p.phase === "playing") {
                root.regressionStopAt = Date.now() + 900;
                root.regressionStep = 3;
            } else if (root.regressionStep === 3 && Date.now() >= root.regressionStopAt) {
                if (!p.stop()) { root.regressionFail("stop_rejected"); return; }
                root.regressionStep = 4;
            } else if (root.regressionStep === 4 && p.phase === "idle") {
                root.regressionCycles++;
                root.regressionLog("cycle_released", {});
                if (!root.regressionOpen()) return;
                if (root.regressionCycles === 3) root.regressionStep = 5;
            } else if (root.regressionStep === 5 && p.phase === "ended") {
                root.regressionLog("natural_end", {});
                if (!p.stop()) { root.regressionFail("final_stop_rejected"); return; }
                root.regressionStep = 6;
            } else if (root.regressionStep === 6 && p.phase === "idle") {
                root.regressionDone = true;
                root.regressionLog("passed", {nativeReleaseAcknowledged: true});
            }
        }
    }
'''


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--runid', required=True, type=gui_session.run_id)
    parser.add_argument('--clip-id', default='X2V_20261011_121750_4284_1', type=gui_session.run_id)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=False)
    check = subprocess.run([sys.executable, str(gui_session.NATIVE/'tests/check_playback_regression.py')],
                           capture_output=True, text=True, timeout=30, cwd=gui_session.PROJECT)
    (output/'regression-gate-check.log').write_text(check.stdout + check.stderr)
    if check.returncode:
        raise RuntimeError('Regression trigger/release gate validation failed; no package prepared')
    source = output/'gui'
    shutil.copytree(gui_session.NATIVE/'ui', source)
    entry = (gui_session.NATIVE/'runtime/main.qml').read_text()
    if not entry.rstrip().endswith('}'):
        raise ValueError('Unexpected native entry point')
    fragment = '''
    function regressionMainModel() {
        if (mainContentLoader.status !== Loader.Ready || !mainContentLoader.item) return null;
        var data = mainContentLoader.item.data;
        for (var i=0; i<Math.min(data.length, 128); ++i) {
            var item = data[i];
            if (item && typeof item.toggle_screen === "function" && item.browseView !== undefined && item.controlScreen !== undefined) return item;
        }
        return null;
    }
    function regressionBrowseReady() { return !!regressionMainModel() && !!extension.browseTarget; }
    function regressionEnterBrowse() { regressionMainModel().toggle_screen("browse_view", {}); }
''' + FRAGMENT.replace('@RUN@', args.runid).replace('@CLIP@', args.clip_id)
    (source/'main.qml').write_text(entry.rstrip()[:-1] + fragment + '\n}\n')
    (output/'test-contract.json').write_text(json.dumps(dict(
        runid=args.runid, clipId=args.clip_id, deployed=False,
        trigger=f'{gui_session.REMOTE}/runs/{args.runid}/playback-test.json',
        triggerFields=dict(enabled=True, runId=args.runid, loggerReady=True,
                           expiresAtMs='camera clock in ms + at most 70000'),
        expectedStopReleaseCycles=3, expectedNaturalEnds=1,
        testMaxSeconds=60, guiSessionMaxSeconds=120,
        requirement='Start and verify a persistent bounded per-PID logger before trigger; require passed marker and restored stock GUI.'
    ), indent=2)+'\n')
    gui_session.prepare(SimpleNamespace(runid=args.runid, seconds=120,
                                        gui=source, output=output/'package'))


if __name__ == '__main__':
    main()
