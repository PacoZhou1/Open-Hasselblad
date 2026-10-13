"""Verified factory USB context; no reset, mode change, or automatic writes."""
from contextlib import contextmanager
import importlib.util
import sys
import usb.core
import usb.util
import usb.backend.libusb1
import libusb_package
from camera_access import SOURCE, EXPECTED

@contextmanager
def connect():
    spec = importlib.util.spec_from_file_location('factory_transport', SOURCE)
    m = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = m
    spec.loader.exec_module(m)
    backend = usb.backend.libusb1.get_backend(find_library=libusb_package.find_library)
    devices = list(usb.core.find(find_all=True, idVendor=0x2756, idProduct=0xb, backend=backend))
    if len(devices) != 1:
        raise RuntimeError('Expected one camera')
    d = devices[0]
    i = d.get_active_configuration()[(4, 0)]
    ep = {e.bEndpointAddress: e for e in i}
    if (i.bInterfaceClass, i.bInterfaceSubClass) != (255, 0) or set(ep) != {5, 6, 0x86, 0x87}:
        raise RuntimeError('USB layout mismatch')
    r = m.FactoryUsbReader(0x2756, 0xb, 4, 0, 6, 0x87, 2500)
    r.device = d
    try:
        usb.util.claim_interface(d, 4)
        r.out_ep, r.in_ep = ep[6], ep[0x87]
        identity = r.factory_shell('getprop ro.product.device;sha256sum /system/bin/camera-service').strip().splitlines()
        if len(identity) != 2 or identity[0] != 'eagle2_hb722' or identity[1].split()[0] != EXPECTED:
            raise RuntimeError('Camera identity/hash mismatch')
        yield r
    finally:
        r.close()
