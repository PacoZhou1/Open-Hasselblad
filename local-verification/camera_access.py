"""X2D II USB identity probe and explicitly requested temporary ADB access."""
import argparse
import importlib.util
import json
from pathlib import Path
import sys
import usb.core
import usb.util
import usb.backend.libusb1
import libusb_package

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'handoff/light/x2d2-project-handoff-2026-10-11/references/x2d-907-one-click-extension-toolkit/src/transport/collect_x2d_af_usb.py'
EXPECTED = '51b9e02f8bfebf388be8dfa163c8e512bee19aeb8ae37a6712727ccc6f26a52d'

def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('action', choices=['identify', 'enable-adb'])
    args = ap.parse_args()
    spec = importlib.util.spec_from_file_location('factory_transport', SOURCE)
    m = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = m
    spec.loader.exec_module(m)
    # Observed X2D II parameter reply; keep sequence and response-type checks.
    m.REPLY_ROUTE_PREFIXES.add(bytes.fromhex('03 00 05 08 0f'))
    backend = usb.backend.libusb1.get_backend(find_library=libusb_package.find_library)
    devices = list(usb.core.find(find_all=True, idVendor=0x2756, idProduct=0x000b, backend=backend))
    if len(devices) != 1:
        raise RuntimeError('Expected exactly one X2D II USB device')
    d = devices[0]
    interface = d.get_active_configuration()[(4, 0)]
    endpoints = {e.bEndpointAddress: e for e in interface}
    if (interface.bInterfaceClass, interface.bInterfaceSubClass) != (255, 0) or set(endpoints) != {5, 6, 0x86, 0x87}:
        raise RuntimeError('USB layout changed; refusing to use assumed endpoints')
    reader = m.FactoryUsbReader(0x2756, 0x000b, 4, 0, 6, 0x87, 2500)
    reader.device = d
    try:
        # Do not reset configuration or select an alternate setting.
        usb.util.claim_interface(d, 4)
        reader.out_ep, reader.in_ep = endpoints[6], endpoints[0x87]
        reply = reader.read_parameter(27)
        print('Firmware:', m.format_parameter_value(27, reply.value), flush=True)
        command = 'getprop ro.product.device;getprop ro.board.platform;id -u;sha256sum /system/bin/camera-service;getprop sys.usb.config'
        output = reader.factory_shell(command)
        print(output, flush=True)
        lines = output.strip().splitlines()
        if len(lines) != 5 or lines[0] != 'eagle2_hb722' or lines[1] != 'eagle2' or lines[2] != '0' or lines[3].split()[0] != EXPECTED:
            raise RuntimeError('Target identity/hash/root mismatch; no USB mode change made')
        result = {'model': lines[0], 'platform': lines[1], 'factory_uid': lines[2], 'camera_service_sha256': lines[3].split()[0], 'usb_config': lines[4], 'firmware': m.format_parameter_value(27, reply.value), 'adb_switch_dispatched': False}
        if args.action == 'identify':
            diagnostic = reader.factory_shell('cat /proc/self/attr/current;getenforce;ls -ldZ /data /data/local /data/local/tmp;ls -lZ /system/bin/camera-service;pidof camera-service')
            print(diagnostic, flush=True)
            result['factory_diagnostic'] = diagnostic
        if args.action == 'enable-adb':
            if lines[4] != 'rndis,mass_storage,bulk,acm':
                raise RuntimeError('Unexpected original USB configuration; refusing switch')
            print(reader.factory_shell(m.FACTORY_ENABLE_USB_ADB_RUNTIME), flush=True)
            result['adb_switch_dispatched'] = True
        (ROOT/'local-verification/camera-access.json').write_text(json.dumps(result, indent=2)+'\n')
    finally:
        reader.close()

if __name__ == '__main__':
    main()
