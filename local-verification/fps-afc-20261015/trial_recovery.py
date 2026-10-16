"""Independent recovery when factory USB cannot reply. Does not claim runtime recovery."""
import shlex,time
SESSION='/system/etc/x2v/x2v_video_session_20261014zl.sh'
BB='/blackbox/x2v-native-20261011'
def adb_restore_baseline(baseline,adb):
    text=baseline.read_text()
    if '/system/lib64/libx2v_preview_aligned_20261015b.so' not in text:
        raise ValueError('Unexpected recovery baseline')
    remote=BB+'/fps-explore/emergency-baseline.sh'
    adb('push',str(baseline),remote)
    # Attempt readonly remount even if copying fails. Preserve failure status.
    adb('shell', 'mount -o remount,rw /system && cp '+shlex.quote(remote)+' '+shlex.quote(SESSION)+' && chmod 755 '+shlex.quote(SESSION)+' && restorecon '+shlex.quote(SESSION)+'; x2v_rc=$?; mount -o remount,ro /system; exit "$x2v_rc"')
    if adb('shell','cat '+shlex.quote(SESSION))!=text:
        raise RuntimeError('Restored session readback differs')
    # Existing supervisor owns stop/finalize/exit. Do not kill a hardware owner.
    # GUI deduplicates identical commands; a non-action token must be observed first.
    adb('shell','echo recovery-idle-'+str(time.time_ns())+' > '+BB+'/gui-cmd')
    time.sleep(1)
    adb('shell','echo photo > '+BB+'/gui-cmd')
    return {'boot_session_restored':True,'photo_requested':True,'runtime_verified':False}
