#!/system/bin/sh
set -e
mount -o remount,rw /system
trap 'mount -o remount,ro /system' EXIT
echo "e2ae59a1fed57dab05bf0907019cf77a036f45022f6d4008f1a093cefb6a762f  /system/lib64/libx2v_cd_observer_20261016.so" | sha256sum -c -
cp /system/lib64/libx2v_cd_observer_20261016.so /blackbox/x2v-native-20261011/classonly-release-20261021/archive/libx2v_cd_observer_20261016.so
echo "e2ae59a1fed57dab05bf0907019cf77a036f45022f6d4008f1a093cefb6a762f  /blackbox/x2v-native-20261011/classonly-release-20261021/archive/libx2v_cd_observer_20261016.so" | sha256sum -c -
rm /system/lib64/libx2v_cd_observer_20261016.so
echo "3da12f9eb5945c93d81c67ba06ecda4a19099b4a468918699c9513ae735affdc  /system/lib64/libx2v_range_observer_20261016.so" | sha256sum -c -
cp /system/lib64/libx2v_range_observer_20261016.so /blackbox/x2v-native-20261011/classonly-release-20261021/archive/libx2v_range_observer_20261016.so
echo "3da12f9eb5945c93d81c67ba06ecda4a19099b4a468918699c9513ae735affdc  /blackbox/x2v-native-20261011/classonly-release-20261021/archive/libx2v_range_observer_20261016.so" | sha256sum -c -
rm /system/lib64/libx2v_range_observer_20261016.so
test ! -e /system/lib64/libx2v_classonly24_20261021a.so
echo "53c69dd1a18f4f5770e984d7c220183755c65849150ec26a551ae9275228264c  /blackbox/x2v-native-20261011/classonly-release-20261021/asset0" | sha256sum -c -
cp /blackbox/x2v-native-20261011/classonly-release-20261021/asset0 /system/lib64/libx2v_classonly24_20261021a.so.tmp
chmod 644 /system/lib64/libx2v_classonly24_20261021a.so.tmp
mv /system/lib64/libx2v_classonly24_20261021a.so.tmp /system/lib64/libx2v_classonly24_20261021a.so
restorecon /system/lib64/libx2v_classonly24_20261021a.so
test ! -e /system/lib64/libx2v_classonly25_20261021a.so
echo "c6834227057ab3c3638754db06eb08db74f108f1023a8cbdd05d9fb083586cdd  /blackbox/x2v-native-20261011/classonly-release-20261021/asset1" | sha256sum -c -
cp /blackbox/x2v-native-20261011/classonly-release-20261021/asset1 /system/lib64/libx2v_classonly25_20261021a.so.tmp
chmod 644 /system/lib64/libx2v_classonly25_20261021a.so.tmp
mv /system/lib64/libx2v_classonly25_20261021a.so.tmp /system/lib64/libx2v_classonly25_20261021a.so
restorecon /system/lib64/libx2v_classonly25_20261021a.so
test ! -e /system/etc/x2v/x2v_video_session_20261021a.sh
echo "c95a29e017d30181961c0b204679e423f3e01eeb9f5929dc3dd4422cd1c796e8  /blackbox/x2v-native-20261011/classonly-release-20261021/asset2" | sha256sum -c -
cp /blackbox/x2v-native-20261011/classonly-release-20261021/asset2 /system/etc/x2v/x2v_video_session_20261021a.sh.tmp
chmod 755 /system/etc/x2v/x2v_video_session_20261021a.sh.tmp
mv /system/etc/x2v/x2v_video_session_20261021a.sh.tmp /system/etc/x2v/x2v_video_session_20261021a.sh
restorecon /system/etc/x2v/x2v_video_session_20261021a.sh
test ! -e /system/etc/x2v/x2v_product_boot_20261021a.sh.pending
echo "e92867b992b3422b0a41e48a0bcb2f99b8ec98d924fd8507697ee98ab54113a5  /blackbox/x2v-native-20261011/classonly-release-20261021/asset3" | sha256sum -c -
cp /blackbox/x2v-native-20261011/classonly-release-20261021/asset3 /system/etc/x2v/x2v_product_boot_20261021a.sh.pending.tmp
chmod 755 /system/etc/x2v/x2v_product_boot_20261021a.sh.pending.tmp
mv /system/etc/x2v/x2v_product_boot_20261021a.sh.pending.tmp /system/etc/x2v/x2v_product_boot_20261021a.sh.pending
restorecon /system/etc/x2v/x2v_product_boot_20261021a.sh.pending
echo OK_install_dependencies
