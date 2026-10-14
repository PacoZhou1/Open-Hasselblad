"""ISP experiment driver: run.py <step> ... on the camera through the factory channel.
  state                   GUI + session summary
  sh '<cmd>'              one factory command
  cdump <name>            the resident's colour-port dump, pulled to exp/isp/<name>.nv12
  bind | unbind           the no-calibration conf + session mounted over the installed ones
  reenter                 video off, then on, through the supervisor
"""
import sys, time
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parents[1]))
import accept as a  # noqa: E402

ETC = '/system/etc/x2v'
EXP = a.G + '/exp-isp'
STATE = ('badge', 'phase', 'session', 'mode', 'stock', 'profile', 'pvShown', 'notice')


def state(f):
    s = a.gui(f)
    print({k: s.get(k) for k in STATE})
    return s


def main():
    step, args = sys.argv[1], sys.argv[2:]
    if step in ('bind', 'cdump'):
        a.setup()
    if step == 'bind':
        a.d.adb('shell', 'mkdir -p %s' % EXP)
        for n in ('nocal.conf', 'session_nocal.sh'):
            a.subprocess.run(['adb', '-s', a.d.SERIAL, 'push', str(HERE / n), EXP + '/' + n], check=True,
                             capture_output=True)
    with a.d.connect() as f:
        if step == 'state':
            state(f)
        elif step == 'sh':
            print(a.fq(f, args[0] + '; true', int(args[1]) if len(args) > 1 else 15000))
        elif step == 'cdump':
            print(a.fq(f, 'sh %s send cdump; ls -l /tmp/x2v-live/colour_a.nv12; true' % a.DEV, 30000))
            a.fq(f, 'cp /tmp/x2v-live/colour_a.nv12 %s/c.nv12; chmod 644 %s/c.nv12; true' % (a.G, a.G), 8000)
            a.d.adb('pull', a.G + '/c.nv12', str(HERE / (args[0] + '.nv12')))
        elif step == 'bind':
            print(a.fq(f, 'mount -o bind %s/nocal.conf %s/imx861bqr_hb722.conf 2>&1; true' % (EXP, ETC), 8000))
            print(a.fq(f, 'mount -o bind %s/session_nocal.sh %s/x2v_video_session_20261014zd.sh 2>&1; true'
                       % (EXP, ETC), 8000))
            print(a.fq(f, 'grep -c calibration=false %s/imx861bqr_hb722.conf; true' % ETC, 8000))
        elif step == 'unbind':
            print(a.fq(f, 'umount %s/x2v_video_session_20261014zd.sh 2>&1; true' % ETC, 8000))
            print(a.fq(f, 'umount %s/imx861bqr_hb722.conf 2>&1; true' % ETC, 8000))
            print(a.fq(f, 'grep -c calibration=true %s/imx861bqr_hb722.conf; true' % ETC, 8000))
        elif step == 'reenter':
            a.gui_cmd('photo')
            a.wait_gui(f, lambda s: s.get('session') == 'down' and s.get('mode') == 'photo', 60, 'exit')
            a.gui_cmd('video')
            s = a.wait_gui(f, lambda s: s.get('session') == 'up' and s.get('phase') in ('idle', 'saved'), 90, 'enter')
            print({k: s.get(k) for k in STATE})


if __name__ == '__main__':
    main()
