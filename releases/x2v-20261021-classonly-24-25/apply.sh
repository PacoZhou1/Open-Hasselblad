#!/system/bin/sh
# Run after stopping recording and exiting video. Incremental package for the 20261017-flat-prr baseline.
set -eu
PAYLOAD=${1:?payload directory required}
ARCHIVE=/blackbox/x2v-native-20261011/classonly-release-20261021/archive
mkdir -p "$ARCHIVE"
mount -o remount,rw /system
trap 'mount -o remount,ro /system' EXIT
if [ -f /system/lib64/libx2v_cd_observer_20261016.so ]; then
 echo "e2ae59a1fed57dab05bf0907019cf77a036f45022f6d4008f1a093cefb6a762f  /system/lib64/libx2v_cd_observer_20261016.so" | sha256sum -c -
 cp /system/lib64/libx2v_cd_observer_20261016.so "$ARCHIVE/libx2v_cd_observer_20261016.so"
 echo "e2ae59a1fed57dab05bf0907019cf77a036f45022f6d4008f1a093cefb6a762f  $ARCHIVE/libx2v_cd_observer_20261016.so" | sha256sum -c -
 rm /system/lib64/libx2v_cd_observer_20261016.so
fi
if [ -f /system/lib64/libx2v_range_observer_20261016.so ]; then
 echo "3da12f9eb5945c93d81c67ba06ecda4a19099b4a468918699c9513ae735affdc  /system/lib64/libx2v_range_observer_20261016.so" | sha256sum -c -
 cp /system/lib64/libx2v_range_observer_20261016.so "$ARCHIVE/libx2v_range_observer_20261016.so"
 echo "3da12f9eb5945c93d81c67ba06ecda4a19099b4a468918699c9513ae735affdc  $ARCHIVE/libx2v_range_observer_20261016.so" | sha256sum -c -
 rm /system/lib64/libx2v_range_observer_20261016.so
fi
echo "53c69dd1a18f4f5770e984d7c220183755c65849150ec26a551ae9275228264c  $PAYLOAD/files/system/lib64/libx2v_classonly24_20261021a.so" | sha256sum -c -
if [ -e /system/lib64/libx2v_classonly24_20261021a.so ]; then
 echo "53c69dd1a18f4f5770e984d7c220183755c65849150ec26a551ae9275228264c  /system/lib64/libx2v_classonly24_20261021a.so" | sha256sum -c -
else
 cp "$PAYLOAD/files/system/lib64/libx2v_classonly24_20261021a.so" /system/lib64/libx2v_classonly24_20261021a.so.tmp
 chmod 644 /system/lib64/libx2v_classonly24_20261021a.so.tmp
 mv /system/lib64/libx2v_classonly24_20261021a.so.tmp /system/lib64/libx2v_classonly24_20261021a.so
 restorecon /system/lib64/libx2v_classonly24_20261021a.so
fi
echo "c6834227057ab3c3638754db06eb08db74f108f1023a8cbdd05d9fb083586cdd  $PAYLOAD/files/system/lib64/libx2v_classonly25_20261021a.so" | sha256sum -c -
if [ -e /system/lib64/libx2v_classonly25_20261021a.so ]; then
 echo "c6834227057ab3c3638754db06eb08db74f108f1023a8cbdd05d9fb083586cdd  /system/lib64/libx2v_classonly25_20261021a.so" | sha256sum -c -
else
 cp "$PAYLOAD/files/system/lib64/libx2v_classonly25_20261021a.so" /system/lib64/libx2v_classonly25_20261021a.so.tmp
 chmod 644 /system/lib64/libx2v_classonly25_20261021a.so.tmp
 mv /system/lib64/libx2v_classonly25_20261021a.so.tmp /system/lib64/libx2v_classonly25_20261021a.so
 restorecon /system/lib64/libx2v_classonly25_20261021a.so
fi
echo "c95a29e017d30181961c0b204679e423f3e01eeb9f5929dc3dd4422cd1c796e8  $PAYLOAD/files/system/etc/x2v/x2v_video_session_20261021a.sh" | sha256sum -c -
if [ -e /system/etc/x2v/x2v_video_session_20261021a.sh ]; then
 echo "c95a29e017d30181961c0b204679e423f3e01eeb9f5929dc3dd4422cd1c796e8  /system/etc/x2v/x2v_video_session_20261021a.sh" | sha256sum -c -
else
 cp "$PAYLOAD/files/system/etc/x2v/x2v_video_session_20261021a.sh" /system/etc/x2v/x2v_video_session_20261021a.sh.tmp
 chmod 755 /system/etc/x2v/x2v_video_session_20261021a.sh.tmp
 mv /system/etc/x2v/x2v_video_session_20261021a.sh.tmp /system/etc/x2v/x2v_video_session_20261021a.sh
 restorecon /system/etc/x2v/x2v_video_session_20261021a.sh
fi
echo "e92867b992b3422b0a41e48a0bcb2f99b8ec98d924fd8507697ee98ab54113a5  $PAYLOAD/files/system/etc/x2v/x2v_product_boot_20261021a.sh" | sha256sum -c -
if [ -e /system/etc/x2v/x2v_product_boot_20261021a.sh ]; then
 echo "e92867b992b3422b0a41e48a0bcb2f99b8ec98d924fd8507697ee98ab54113a5  /system/etc/x2v/x2v_product_boot_20261021a.sh" | sha256sum -c -
else
 cp "$PAYLOAD/files/system/etc/x2v/x2v_product_boot_20261021a.sh" /system/etc/x2v/x2v_product_boot_20261021a.sh.tmp
 chmod 755 /system/etc/x2v/x2v_product_boot_20261021a.sh.tmp
 mv /system/etc/x2v/x2v_product_boot_20261021a.sh.tmp /system/etc/x2v/x2v_product_boot_20261021a.sh
 restorecon /system/etc/x2v/x2v_product_boot_20261021a.sh
fi
echo OK_install
