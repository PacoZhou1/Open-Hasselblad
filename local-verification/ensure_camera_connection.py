"""Restore temporary ADB after a known camera reboot; never reset USB identity."""
import json,subprocess,sys,time
from pathlib import Path
import usb.core
from factory_session import connect

def ensure_adb():
    owner=json.loads((Path(__file__).parent/'camera-testing.lock/owner.json').read_text())
    assert owner['owner']=='codex-preview-debug' and owner['state']=='TESTING'
    def ready():
        r=subprocess.run(['adb','-s','123456789ABCDEF','get-state'],capture_output=True,text=True,timeout=3)
        return r.returncode==0 and r.stdout.strip()=='device'
    if ready():return {'temporary_adb_enabled':False}
    devices=list(usb.core.find(find_all=True,idVendor=0x2756,idProduct=0xb))
    if len(devices)!=1:raise RuntimeError('Camera USB is not connected; ADB absence alone is not a USB inventory')
    with connect(verify_identity=False) as r:
        m=sys.modules['factory_transport'];m.REPLY_ROUTE_PREFIXES.add(bytes.fromhex('03 00 05 08 0f'))
        fw=m.format_parameter_value(27,r.read_parameter(27).value)
        assert '1.3.16.2' in fw,fw
        config=r.factory_shell('getprop sys.usb.config',capture_ms=2500).strip()
        assert config in ['rndis,mass_storage,bulk,acm','rndis,mass_storage,bulk,acm,adb'],config
        if not config.endswith(',adb'):
            r.factory_shell(m.FACTORY_ENABLE_USB_ADB_RUNTIME,capture_ms=2500)
    # Native runtime switch deliberately takes two seconds. Poll for completion,
    # returning on the first usable reply instead of a fixed long wait.
    end=time.monotonic()+6
    while time.monotonic()<end:
        if ready():return {'temporary_adb_enabled':not config.endswith(',adb'),'firmware':fw}
        time.sleep(.2)
    raise RuntimeError('Camera USB is present, but temporary ADB did not become ready')
