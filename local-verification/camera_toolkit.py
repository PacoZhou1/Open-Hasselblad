#!/usr/bin/env python3
"""One bounded screen recording and export, with owned-session cleanup.

This captures the Qt Quick GUI. Stock LiveView's external image plane may appear
black; menus and VideoItem playback can be captured. This is not sensor recording.
"""
import argparse
import contextlib
import io
import json
import math
import os
from pathlib import Path
import re
import secrets
import shutil
import signal
import subprocess
import sys
import time
from types import SimpleNamespace

import gui_session
import screen_audit

PROJECT = Path(__file__).resolve().parents[1]
NATIVE = PROJECT/'native-video'
ROOT = gui_session.REMOTE
LOADER = '/system/lib64/libx2v_gui_bootstrap_20261011.so'
RECORDER_PROCESS_QUERY = "ps -A | awk 'NR==1 {print; next} {name=$NF; sub(/^.*\\//, \"\", name); if (name ~ /^(x2v_recorder|rtp_recorder)/) print}'"
LIMITATION = '只采集 Qt Quick 界面：原厂 LiveView 图像可能呈黑底或缺失；菜单和 VideoItem 回看画面可采集。不是传感器视频内录。'


class ToolkitError(RuntimeError):
    pass


class Interrupted(ToolkitError):
    pass


def recorder_pids(process_table):
    lines = [line.split() for line in process_table.splitlines() if line.strip()]
    if not lines or 'PID' not in lines[0] or 'NAME' not in lines[0]:
        raise ToolkitError('无法解析相机进程表；拒绝切换界面。')
    pid_col, name_col = lines[0].index('PID'), lines[0].index('NAME')
    result = []
    for row in lines[1:]:
        if len(row) <= max(pid_col, name_col) or not row[pid_col].isdigit():
            raise ToolkitError('相机进程表存在不完整记录；拒绝切换界面。')
        name = row[name_col].rsplit('/', 1)[-1]
        if name.startswith(('x2v_recorder', 'rtp_recorder')):
            result.append(int(row[pid_col]))
    return result


def camera_transport(camera_state):
    matches = re.findall(r'^liveview_transport_mode_current\s*=\s*E_LiveviewTransportMode_([A-Za-z0-9_]+)\(\d+\)\s*$', camera_state, re.M)
    if len(matches) != 1:
        raise ToolkitError('无法确认相机预览传输状态；拒绝切换界面。')
    return matches[0]


class Runtime:
    """Device-facing operations, isolated so orchestration can be tested offline."""
    def __init__(self):
        self.serial = gui_session.SERIAL

    def lock_owner(self):
        output = gui_session.adb('shell', f'if [ -e {ROOT}/gui-session.lock ]; then cat {ROOT}/gui-session.lock/owner 2>/dev/null || echo UNKNOWN; else echo NONE; fi').strip()
        if output == 'NONE':
            return None
        fields = output.split()
        if len(fields) != 3 or not fields[1].isdigit() or not fields[2].isdigit():
            return dict(runid='UNKNOWN', rawOwnerInvalid=True)
        return dict(runid=fields[0], pid=int(fields[1]), starttime=fields[2])

    def audit_config(self):
        raw = gui_session.adb('shell', f'cat {screen_audit.CONFIG_PATH} 2>/dev/null || true').strip()
        if not raw:
            return {}
        value = json.loads(raw)
        if not isinstance(value, dict):
            raise ToolkitError('相机上的 audit-config.json 格式无效；未修改该文件。')
        return value

    def preflight(self):
        raise ToolkitError('EXECUTION_HOLD：旧版录屏仍将恢复状态和批量帧存入原厂管理的 blackbox；'
                           '实机已发生目录被清理。需完成 data/SSD 迁移后才能重新启用。未连接或改动相机。')
        gui_session.verify_device()
        try:
            digest = gui_session.adb('shell', f'sha256sum {LOADER}').split()[0]
        except (subprocess.SubprocessError, IndexError) as exc:
            raise ToolkitError('相机缺少可读取的既有 bootstrap 库；本工具不会安装或修改系统库。') from exc
        if digest != gui_session.LOADER_SHA:
            raise ToolkitError('bootstrap 库 SHA 不匹配；已拒绝启动，未修改系统库。')
        from factory_session import connect
        with connect() as factory:
            gui_state = factory.factory_shell('getprop init.svc.camera-gui', capture_ms=900).strip()
            gui_pids = factory.factory_shell('pidof camera-gui || true', capture_ms=900).split()
            # Filter on the device: returning the complete process list can
            # exceed the bounded factory USB response and hide the terminator.
            # NAME can be a basename or an absolute executable path.
            recorders = recorder_pids(factory.factory_shell(
                RECORDER_PROCESS_QUERY, capture_ms=1800))
            state = factory.factory_shell('timeout 4 odindb-send -s camera -p live_view_state,liveview_transport_mode_current', capture_ms=4500)
        transport = camera_transport(state)
        if any(not pid.isdigit() for pid in gui_pids):
            raise ToolkitError('无法可靠识别相机 GUI/录制器进程；拒绝切换界面。')
        clock_ms = int(gui_session.adb('shell', 'date +%s').strip())*1000
        config = self.audit_config()
        active = config.get('enabled') is True and float(config.get('expiresAtMs', 0)) > clock_ms
        return dict(lock=self.lock_owner(), stockGuiState=gui_state,
                    guiPids=[int(x) for x in gui_pids], recorderPids=recorders,
                    ssdRecordingProcessPresent=bool(recorders), loaderSha256=digest,
                    liveviewTransport=transport, cameraState=state.strip(),
                    activeAudit=active, auditRunId=config.get('runId'),
                    deviceClockMs=clock_ms, deviceIdentityVerified=True)

    def verify_attach(self, identity):
        gui_session.run_id(identity)
        state = gui_session.status_data(identity)
        if state['phase'] != 'running':
            raise ToolkitError('指定 GUI 会话当前不是 running 状态。')
        # An explicit attach reuses only the known bounded audit implementation.
        for name in ['AuditControl.qml', 'ScreenAudit.qml']:
            expected = gui_session.sha(NATIVE/'ui'/name)
            actual = gui_session.adb('shell', f'sha256sum {ROOT}/gui/{name}').split()[0]
            if actual != expected:
                raise ToolkitError('现有 GUI 的采集组件不是当前已测试版本，拒绝挂接。')
        return state

    def prepare(self, identity, seconds, directory):
        source = directory/'audit-gui'
        source.mkdir()
        shutil.copy2(NATIVE/'runtime/audit-main.qml', source/'main.qml')
        for name in ['AuditControl.qml', 'ScreenAudit.qml']:
            shutil.copy2(NATIVE/'ui'/name, source/name)
        # Dedicated audit validation supplements the shared GUI session checks.
        before = {p.name:gui_session.sha(p) for p in source.iterdir()}
        test = subprocess.run([sys.executable, str(NATIVE/'tests/check_screen_audit.py')], cwd=PROJECT,
                              capture_output=True, text=True, timeout=120)
        (directory/'screen-audit-desktop-check.log').write_text(test.stdout+test.stderr)
        if test.returncode:
            raise ToolkitError('屏幕采集组件桌面检查失败，未连接/切换 GUI。')
        if {p.name:gui_session.sha(p) for p in source.iterdir()} != before:
            raise ToolkitError('打包期间采集源文件发生变化，拒绝部署。')
        package = directory/'package'
        with contextlib.redirect_stdout(io.StringIO()) as captured:
            try:
                gui_session.prepare(SimpleNamespace(runid=identity, seconds=seconds, gui=source, output=package))
            finally:
                (directory/'prepare.log').write_text(captured.getvalue())
        return package

    def deploy(self, package, directory):
        with contextlib.redirect_stdout(io.StringIO()) as captured:
            try:
                gui_session.deploy(SimpleNamespace(package=package))
            finally:
                (directory/'deploy.log').write_text(captured.getvalue())
        return json.loads((package/'deployment.json').read_text())

    def gui_status(self, identity):
        return gui_session.status_data(identity)

    def start_audit(self, identity, seconds, fps, format):
        return screen_audit.start_device(self.serial, identity, seconds, fps, format)

    def events(self, identity):
        remote = f'{screen_audit.DEVICE_ROOT}/{screen_audit.validate_run_id(identity)}/events.log'
        text = gui_session.adb('shell', f'cat {remote} 2>/dev/null || true')
        return screen_audit.parse_events(text, identity)

    def stop_config(self, identity):
        config = self.audit_config()
        if config.get('runId') != identity:
            return dict(stopRequested=False, reason='audit_config_owned_by_another_run')
        # Do not let stop_device choose a newly observed unrelated runId.
        screen_audit.write_config(self.serial, dict(enabled=False, runId=identity, expiresAtMs=0))
        readback = self.audit_config()
        return dict(stopRequested=True, confirmed=readback.get('runId') == identity and readback.get('enabled') is False)

    def collect(self, identity, directory):
        return screen_audit.collect_device(self.serial, identity, directory/'capture', render=True)

    def stop_gui(self, identity, directory):
        with contextlib.redirect_stdout(io.StringIO()) as captured:
            try:
                gui_session.stop(SimpleNamespace(runid=identity))
            finally:
                (directory/'gui-stop.log').write_text(captured.getvalue())
        return gui_session.status_data(identity)

    def restoration(self, identity):
        # The supervisor and its independent recovery process may still be
        # finishing after the stop command returns. Wait for their durable
        # completion marker before judging the stock GUI readback.
        deadline = self.monotonic()+8
        while True:
            status = self.gui_status(identity)
            lock = self.lock_owner()
            if status['phase'] == 'restored' and not lock:
                break
            if status['phase'].startswith('error_') or self.monotonic() >= deadline:
                break
            self.sleep(.2)
        from factory_session import connect
        with connect() as factory:
            state = factory.factory_shell('getprop init.svc.camera-gui', capture_ms=900).strip()
            pids = factory.factory_shell('pidof camera-gui || true', capture_ms=900).strip()
        lock = self.lock_owner()
        return dict(session=status, stockGuiState=state, stockGuiPids=pids,
                    guiLock=lock, confirmed=status['phase'] == 'restored' and state == 'running' and bool(pids) and not lock)

    def sleep(self, seconds):
        time.sleep(seconds)

    def monotonic(self):
        return time.monotonic()


def validate(args):
    if not isinstance(args.seconds, (int, float)) or not math.isfinite(args.seconds) or not 1 <= args.seconds <= 60:
        raise ToolkitError('seconds 必须在 1–60 之间；单次最多 80 帧。')
    if not isinstance(args.fps, int) or not 1 <= args.fps <= 5:
        raise ToolkitError('fps 必须是 1–5 的整数。')
    if args.format not in ('bmp', 'png'):
        raise ToolkitError('format 必须为 bmp 或 png。')
    if args.attach:
        gui_session.run_id(args.attach)


def require_safe(snapshot, attach):
    if snapshot.get('activeAudit'):
        raise ToolkitError('相机已有有效的屏幕采集 lease；未覆盖该采集。')
    lock = snapshot.get('lock')
    if attach:
        if not lock or lock.get('runid') != attach:
            raise ToolkitError('--attach 必须与当前统一 GUI 锁的会话 ID 完全一致。')
        if len(snapshot.get('guiPids', [])) != 1:
            raise ToolkitError('挂接需要唯一的现有 GUI 进程。')
        return
    if lock:
        raise ToolkitError('相机已有 GUI 会话，拒绝替换；如需采集当前会话，请显式使用 --attach RUNID。')
    if snapshot.get('recorderPids'):
        raise ToolkitError('检测到机内/SSD 录制器仍运行，拒绝切换 GUI。')
    if snapshot.get('liveviewTransport') != 'None':
        raise ToolkitError('相机正在使用 RTP/USB 或未知预览传输，拒绝重新加载 GUI。')
    if snapshot.get('stockGuiState') != 'running' or len(snapshot.get('guiPids', [])) != 1:
        raise ToolkitError('原厂 GUI 状态不明确，拒绝启动临时界面。')


def record(args, runtime=None, stop_requested=None):
    runtime = runtime or Runtime()
    stop_requested = stop_requested or (lambda: False)
    nonce = secrets.token_hex(8)
    audit_id = 'audit-'+nonce
    gui_id = args.attach or 'screen-'+nonce
    directory = Path(args.output).resolve() if args.output else NATIVE/'outputs/camera-toolkit'/audit_id
    directory.mkdir(parents=True, exist_ok=False)
    report = dict(schema=1, auditRunId=audit_id, guiRunId=gui_id, attached=bool(args.attach),
                  requestedSeconds=args.seconds if isinstance(args.seconds, (int, float)) and math.isfinite(args.seconds) else str(args.seconds),
                  fps=args.fps, format=args.format,
                  limitation=LIMITATION, phase='preflight', success=False, errors=[], cleanup={},
                  deviceMutations=[], report=str(directory/'report.json'))
    deployment_attempted = False
    attached_verified = False
    audit_attempted = False
    capture_stopped = False
    collection_attempted = False

    def save():
        temp = directory/'report.json.tmp'
        temp.write_text(json.dumps(report, ensure_ascii=False, indent=2)+'\n')
        os.replace(temp, directory/'report.json')

    def error(where, exc):
        report['errors'].append(dict(where=where, type=type(exc).__name__, message=str(exc)))
        save()

    def interrupted():
        if stop_requested():
            raise Interrupted('用户中断；正在停止本轮采集并恢复本轮 GUI。')

    save()
    try:
        validate(args)
        report['effectiveSeconds'] = min(args.seconds, 80/args.fps)
        report['sessionMaxSeconds'] = min(180, math.ceil(args.seconds+60))
        report['preflight'] = runtime.preflight()
        require_safe(report['preflight'], args.attach)
        interrupted()
        if args.attach:
            report['attachedStatus'] = runtime.verify_attach(gui_id)
            attached_verified = True
        else:
            report['phase'] = 'prepare'; save()
            package = runtime.prepare(gui_id, report['sessionMaxSeconds'], directory)
            interrupted()
            # Preparation takes time; recheck before any GUI session replacement.
            report['predeploy'] = runtime.preflight()
            require_safe(report['predeploy'], None)
            report['phase'] = 'deploy'; save(); deployment_attempted = True
            report['deployment'] = runtime.deploy(package, directory)
            report['deviceMutations'].append('owned_temporary_gui_session')
            limit = runtime.monotonic()+12
            while True:
                interrupted()
                status = runtime.gui_status(gui_id)
                report['guiStatus'] = status
                if status['phase'] == 'running':
                    break
                if status['phase'] == 'restored' or status['phase'].startswith('error_'):
                    raise ToolkitError('临时 GUI 未进入 running；已保留启动状态。')
                if runtime.monotonic() >= limit:
                    raise ToolkitError('临时 GUI 启动状态等待超时。')
                runtime.sleep(.25)
        interrupted()
        owner = runtime.lock_owner()
        if not owner or owner.get('runid') != gui_id:
            raise ToolkitError('启动采集前 GUI 会话所有权已变化；未写入采集配置。')
        report['phase'] = 'starting_capture'; save(); audit_attempted = True
        report['auditStart'] = runtime.start_audit(audit_id, args.seconds, args.fps, args.format)
        report['deviceMutations'].append('bounded_screen_audit_lease')
        report['phase'] = 'capturing'; save()
        started = runtime.monotonic()
        deadline = started + report['effectiveSeconds'] + 8
        saw_start = False
        while runtime.monotonic() < deadline:
            interrupted()
            if runtime.gui_status(gui_id)['phase'] != 'running':
                raise ToolkitError('采集期间 GUI 会话已退出；将导出已保存的帧。')
            events = runtime.events(audit_id)
            saw_start = saw_start or any(e.get('event') == 'started' for e in events)
            stop_events = [e for e in events if e.get('event') == 'stopped']
            if stop_events:
                report['captureStop'] = stop_events[-1]
                capture_stopped = True
                if report['captureStop'].get('reason') not in ('duration_limit', 'frame_limit'):
                    raise ToolkitError('采集提前停止：'+str(report['captureStop'].get('reason', 'unknown')))
                break
            if not saw_start and runtime.monotonic()-started > 6:
                raise ToolkitError('没有收到采集 started 事件；不将空录像视为成功。')
            runtime.sleep(.5)
        if not capture_stopped:
            raise ToolkitError('采集未在有界时间内报告停止；正在请求关闭并保存证据。')
    except BaseException as exc:
        error('capture', exc)
    finally:
        # Cleanup ignores the first requested interruption and always continues to
        # the next independent cleanup step if one operation fails.
        if audit_attempted:
            try:
                report['cleanup']['auditConfig'] = runtime.stop_config(audit_id)
                stopped = report['cleanup']['auditConfig']
                if stopped.get('stopRequested') and not stopped.get('confirmed'):
                    raise ToolkitError('屏幕采集关闭配置尚未确认；继续收集和恢复 GUI。')
            except BaseException as exc:
                error('stop_config', exc)
            save()
        if audit_attempted:
            try:
                # Give the QML config poll/in-flight callback a bounded drain.
                runtime.sleep(1.2)
                report['phase'] = 'collecting'; save(); collection_attempted = True
                result = runtime.collect(audit_id, directory)
                report['capture'] = dict(capturedFrames=result.get('capturedFrames', 0),
                                         runStopObserved=result.get('runStopObserved', False),
                                         video=result.get('video'), output=str(directory/'capture'))
                if not report['capture']['capturedFrames']:
                    raise ToolkitError('未收集到带成功事件的帧；已保留日志。')
                if not report['capture']['runStopObserved']:
                    raise ToolkitError('导出未包含 stopped 事件；保留为未完成采集。')
            except BaseException as exc:
                error('collect', exc)
        if deployment_attempted and not args.attach:
            try:
                owner = runtime.lock_owner()
                if owner and owner.get('runid') == gui_id:
                    report['cleanup']['guiStop'] = runtime.stop_gui(gui_id, directory)
                else:
                    report['cleanup']['guiStop'] = dict(skipped=True, reason='this_run_does_not_own_current_lock')
            except BaseException as exc:
                error('stop_gui', exc)
            try:
                report['cleanup']['restoration'] = runtime.restoration(gui_id)
                if not report['cleanup']['restoration']['confirmed']:
                    raise ToolkitError('尚未确认原厂 GUI 恢复；请检查 report 中的相机状态。')
            except BaseException as exc:
                error('restore_gui', exc)
        elif attached_verified:
            try:
                report['cleanup']['attachedGui'] = runtime.gui_status(gui_id)
                report['cleanup']['existingGuiStoppedByToolkit'] = False
            except BaseException as exc:
                error('attached_status', exc)
        report['phase'] = 'complete' if not report['errors'] else 'incomplete'
        report['success'] = not report['errors'] and capture_stopped and collection_attempted and bool(report.get('capture', {}).get('capturedFrames'))
        save()
    return report


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest='command', required=True)
    p = sub.add_parser('record', help='有界屏幕采集并导出；不启动传感器录像')
    p.add_argument('--seconds', type=float, default=30)
    p.add_argument('--fps', type=int, default=2)
    p.add_argument('--format', choices=('bmp', 'png'), default='bmp')
    p.add_argument('--attach', metavar='RUNID', help='显式采集已有 GUI；结束时保留该 GUI/录制会话')
    p.add_argument('--output', type=Path)
    args = parser.parse_args(argv)
    requested = []
    def interrupt(signum, frame):
        requested.append(signum)
    for sig in (signal.SIGINT, signal.SIGTERM, signal.SIGHUP):
        signal.signal(sig, interrupt)
    print(LIMITATION, flush=True)
    result = record(args, stop_requested=lambda: bool(requested))
    print(json.dumps(dict(success=result['success'], report=result['report'], capture=result.get('capture'),
                         errors=result['errors'], cleanup=result['cleanup']), ensure_ascii=False, indent=2))
    return 0 if result['success'] else 1


if __name__ == '__main__':
    sys.exit(main())
