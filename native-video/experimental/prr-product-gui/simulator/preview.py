#!/usr/bin/env python3
"""Offline product-GUI preview. Keys and msdec RGB surface; no camera."""
import argparse
import hashlib
import json
import os
import shutil
import sys
import tempfile
from pathlib import Path

from PySide6.QtCore import QPoint, Qt, QUrl, qInstallMessageHandler
from PySide6.QtQml import QQmlApplicationEngine, QQmlAbstractUrlInterceptor, QQmlComponent, QQmlEngine
from PySide6.QtTest import QTest
from PySide6.QtWidgets import QApplication

p = argparse.ArgumentParser()
p.add_argument('--check', action='store_true')
a = p.parse_args()
if a.check:
    os.environ.update(QT_QPA_PLATFORM='offscreen', QT_QUICK_BACKEND='software')

HERE = Path(__file__).resolve().parent
PRODUCT = HERE.parent
NATIVE = HERE.parents[2]
UIK = NATIVE / 'experimental/manual-video-product-ui-k'
sys.path.insert(0, str(NATIVE / 'simulator'))
sys.path.insert(0, str(HERE))
from play_server import start as start_play
from simulator import Simulator, SvgProvider, load_fonts

messages = []
qInstallMessageHandler(lambda k, c, m: messages.append({'type': k.name, 'message': m}))
app = QApplication([])
load_fonts(app)
from PySide6.QtCore import QTranslator
translator = QTranslator()
assert translator.load(str(NATIVE.parent / 'resources/gui-resources/5/translations/camera_zh_CN.qm'))
app.installTranslator(translator)
engine = QQmlApplicationEngine()
engine.addImportPath(str(NATIVE / 'simulator/cache/imports'))


class StockMapper(QQmlAbstractUrlInterceptor):
    def intercept(self, url, dt):
        prefix = 'qrc:/qt/qml/app/qml/'
        return QUrl.fromLocalFile(str(NATIVE / 'simulator/cache/stock' / url.toString()[len(prefix):])) if url.toString().startswith(prefix) else url


mapper = StockMapper()
engine.addUrlInterceptor(mapper)
receipt = json.loads((NATIVE / 'simulator/cache/provenance.json').read_text())
sim = Simulator(receipt)
engine.addImageProvider('svg', SvgProvider(receipt['assets']))
engine.rootContext().setContextProperty('sim', sim)


def make_ppm(path, w, h, rgb):
    inner = (rgb[0] // 2 + 40, rgb[1] // 2 + 40, rgb[2] // 2 + 40)
    pix = bytearray()
    for y in range(h):
        for x in range(w):
            pix.extend(inner if 80 <= x < w - 80 and 80 <= y < h - 80 else rgb)
    data = f'P6\n{w} {h}\n255\n'.encode() + pix
    Path(path).write_bytes(data)
    return data, w, h


def fixture_dir(td):
    root = Path(td)
    live = make_ppm(root / 'liveview.ppm', 1024, 768, (28, 32, 36))
    thumb = make_ppm(root / 'thumb.ppm', 320, 240, (60, 48, 36))
    frames = [
        make_ppm(root / 'f0.ppm', 972, 728, (180, 70, 50)),
        make_ppm(root / 'f1.ppm', 972, 728, (50, 160, 80)),
        make_ppm(root / 'f2.ppm', 972, 728, (40, 70, 190)),
    ]
    (root / 'clip.mov').write_bytes(b'ftyp' * 1024)
    return root, frames, live, thumb


td = tempfile.TemporaryDirectory(prefix='x2v-prr-sim-')
root, frames, live, thumb = fixture_dir(td.name)
server, play_state = start_play(frames, host='127.0.0.1', port=0, fps=4.0, frame_path=str(root / 'play_frame.ppm'))
port = server.server_address[1]
keys_imports = Path(td.name) / 'qml-imports'
keys_folder = keys_imports / 'com/hasselblad/keys'
keys_folder.mkdir(parents=True)
(keys_folder / 'qmldir').write_text('module com.hasselblad.keys\nsingleton KeyFn 1.0 KeyFn.qml\n')
(keys_folder / 'KeyFn.qml').write_text(
    'pragma Singleton\nimport QtQuick\nQtObject {'
    ' enum Values { Play=1, FullPress=2, E_Button_FullPress=15 }'
    ' function isFn(k,m,fn){return false}'
    ' function isButton(b,k){return false} }\n')
engine.addImportPath(str(keys_imports))

engine.load(QUrl.fromLocalFile(str(HERE / 'Preview.qml')))
assert engine.rootObjects(), messages
w = engine.rootObjects()[0]
w.setProperty('fixtureRoot', str(root))
w.setProperty('playerBase', f'http://127.0.0.1:{port}')
engine.globalObject().setProperty('w', engine.newQObject(w))


def js(s):
    v = engine.evaluate(s)
    assert not v.isError(), v.toString()
    return v.toVariant()


js('w.loadCatalog()')
if not a.check:
    sys.exit(app.exec())

EVIDENCE = PRODUCT / 'evidence'
EVIDENCE.mkdir(exist_ok=True)
checks = []


def check(n, s):
    assert js(s), (n, js(s))
    checks.append(n)


def shot(n):
    QTest.qWait(60)
    viewport = w.property('cameraViewport')
    grab = viewport.grabToImage()
    for _ in range(50):
        QTest.qWait(10)
        if not grab.image().isNull():
            break
    assert grab.saveToFile(str(EVIDENCE / n))


QTest.qWait(400)
check('RAW selected and backend match enables record',
      'w.profiles.selected.raw && w.profiles.canRecord && w.profiles.selected.format==="ProRes RAW HQ"')
check('Idle liveview hides status badge', '!w.recordOverlay.badgeVisible')
check('Catalog accepts PRR mov',
      'w.playback.clips.length===1 && String(w.playback.clips[0].source).indexOf(".mov")>0')
shot('01-liveview-clean.png')

js('w.screen="settings"')
QTest.qWait(80)
check('Settings open without idle 视频 badge', 'w.settings.visible && !w.recordOverlay.visible')
shot('02-settings-no-overlay.png')
QTest.mouseClick(w, Qt.LeftButton, Qt.NoModifier, QPoint(512, 148))
check('Resolution chooser still works', 'w.settings.page==="resolution" && w.settings.options.length===2')
shot('03-resolution-chooser.png')
js('w.settings.page="";w.screen="live"')

check('Video-mode body keys do not steal focus or override stock keys',
      'w.bodyKeys.keyOverride===0 && w.bodyKeys.focus===false')
check('Half press is not consumed', '!w.simulateHardware("half_press",false)')
js('w.simulateHardware("full_press",false);w.simulateHardware("full_press",true)')
QTest.qWait(400)
check('Shutter full press starts one recording',
      'w.startCalls===1 && w.recorder.phase==="recording" && w.recordOverlay.badgeVisible')
shot('04-recording-shutter.png')
js('w.simulateHardware("full_press",false);w.simulateHardware("full_press",true)')
QTest.qWait(200)
check('Second full press stops', 'w.stopCalls===1')
QTest.qWait(1800)
check('Recorder returns to idle after stop', 'w.recorder.phase==="idle"')
js('w.recorder.videoMode=false')
check('Still mode shutter is not consumed', '!w.simulateHardware("full_press",false)')
js('w.recorder.videoMode=true')

js('w.simulatePlay()')
QTest.qWait(80)
check('Body Playback opens gallery', 'w.gallery.visible===true && w.playback.clips.length===1')
shot('05-gallery-play-key.png')
assert js('w.playback.open("X2V_PRR_SIM")')
for _ in range(40):
    QTest.qWait(50)
    if js('["playing","ended"].indexOf(w.playback.phase)>=0'):
        break
assert js('(w.playback.phase==="playing" || w.playback.phase==="ended") && !w.playback.error'), (
    'msdec RGB', js('w.playback.phase'), js('w.playback.error'), play_state.snapshot())
checks.append('Playback is msdec RGB phase, not a VideoItem error')
shot('06-msdec-rgb-surface.png')
js('w.simulatePlay()')
QTest.qWait(80)
check('Play during playback stops the surface',
      'w.playback.phase==="idle" || w.playback.phase==="stopping"')
js('w.playback.stop();w.gallery.visible=false;w.screen="drive"')
QTest.qWait(80)
check('Drive still has video tile', 'w.drive.count===7')
shot('07-drive-mode.png')

with tempfile.TemporaryDirectory(prefix='x2v-prr-compile-') as ctd:
    imports = Path(ctd) / 'imports'
    staged = Path(ctd) / 'gui'
    staged.mkdir()
    runtime = NATIVE / 'runtime/gui'
    uik = UIK / 'gui'
    for name in ['Catalog.js', 'PlaybackSession.qml', 'VideoGallery.qml', 'VideoPlaybackControls.qml']:
        shutil.copy2(runtime / name, staged / name)
    for name in ['RecordingProfiles.qml', 'ExperimentalVideoSettings.qml', 'ExperimentalVideoUi.qml',
                 'ExperimentalMenuEntry.qml', 'VideoDriveGrid.qml', 'RecordingOverlay.qml']:
        shutil.copy2(uik / name, staged / name)
    for name in ['main.qml', 'DriveAttach.qml', 'BodyKeys.qml', 'PrrFrameSurface.qml', 'ExposureTouchTabs.qml']:
        shutil.copy2(PRODUCT / name, staged / name)
    for name, symbol, body in [
        ('video', 'VideoItem', 'import QtQuick\nItem {property string source:"";property int status:0;enum Status {Playing,Done,Error}}'),
        ('keys', 'KeyFn', 'pragma Singleton\nimport QtQuick\nQtObject { enum Values { Play=1, FullPress=2, E_Button_FullPress=15 } function isFn(k,m,fn){return false} function isButton(b,k){return false} }'),
    ]:
        folder = imports / 'com/hasselblad' / name
        folder.mkdir(parents=True)
        (folder / 'qmldir').write_text(
            'module com.hasselblad.' + name + '\n' +
            ('singleton ' if name == 'keys' else '') + symbol + ' 1.0 ' + symbol + '.qml\n')
        (folder / (symbol + '.qml')).write_text(body)
    compiler = QQmlEngine()
    compiler.addImportPath(str(NATIVE / 'simulator/cache/imports'))
    compiler.addImportPath(str(imports))
    compiler.addUrlInterceptor(mapper)
    component = QQmlComponent(compiler, QUrl.fromLocalFile(str(staged / 'main.qml')))
    assert component.status() == QQmlComponent.Ready, [e.toString() for e in component.errors()]
    checks.append('Product overlay main.qml compiles as assembled')

warnings = [m for m in messages if m['type'] in ['QtWarningMsg', 'QtCriticalMsg', 'QtFatalMsg']]
# Localhost RGB player and missing stock C++ types are expected on desktop.
ignore = ('VideoItem', 'com.hasselblad.video', 'msdec', 'file://', 'X2V_')
warnings = [m for m in warnings if not any(x in m['message'] for x in ignore)]
result = {
    'passed': True,
    'checks': checks,
    'count': len(checks),
    'warnings': warnings,
    'camera_access': False,
    'player': f'http://127.0.0.1:{port}',
    'scope': 'Desktop product chrome/keys/msdec-RGB surface; no HEVC and no camera',
    'device_ready': False,
    'sources': {str(x.relative_to(PRODUCT)): hashlib.sha256(x.read_bytes()).hexdigest()
                for x in list(PRODUCT.glob('*.qml')) + list(PRODUCT.glob('*.js'))},
}
(EVIDENCE / 'prr-product-qt-report.json').write_text(json.dumps(result, indent=2, ensure_ascii=False) + '\n')
print('PASS', len(checks), 'product GUI checks')
td.cleanup()
server.shutdown()
