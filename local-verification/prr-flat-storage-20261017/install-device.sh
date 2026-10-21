#!/system/bin/sh
set -e
mount -o remount,rw /system
trap 'mount -o remount,ro /system' EXIT
test ! -e /system/etc/x2v/x2v_video_session_20261017flat.sh
cp /blackbox/x2v-native-20261011/flat-prr-20261017/asset0 /system/etc/x2v/x2v_video_session_20261017flat.sh.tmp
chmod 755 /system/etc/x2v/x2v_video_session_20261017flat.sh.tmp
mv /system/etc/x2v/x2v_video_session_20261017flat.sh.tmp /system/etc/x2v/x2v_video_session_20261017flat.sh
restorecon /system/etc/x2v/x2v_video_session_20261017flat.sh
test ! -e /system/etc/x2v/x2v_flat_storage_20261017a.sh
cp /blackbox/x2v-native-20261011/flat-prr-20261017/asset2 /system/etc/x2v/x2v_flat_storage_20261017a.sh.tmp
chmod 755 /system/etc/x2v/x2v_flat_storage_20261017a.sh.tmp
mv /system/etc/x2v/x2v_flat_storage_20261017a.sh.tmp /system/etc/x2v/x2v_flat_storage_20261017a.sh
restorecon /system/etc/x2v/x2v_flat_storage_20261017a.sh
test ! -e /system/bin/x2v_sync_paths_20261017a
cp /blackbox/x2v-native-20261011/flat-prr-20261017/asset3 /system/bin/x2v_sync_paths_20261017a.tmp
chmod 755 /system/bin/x2v_sync_paths_20261017a.tmp
mv /system/bin/x2v_sync_paths_20261017a.tmp /system/bin/x2v_sync_paths_20261017a
restorecon /system/bin/x2v_sync_paths_20261017a
test ! -e /system/etc/x2v/x2v_product_boot_20261017a.sh
cp /blackbox/x2v-native-20261011/flat-prr-20261017/asset1 /system/etc/x2v/x2v_product_boot_20261017a.sh.tmp
chmod 755 /system/etc/x2v/x2v_product_boot_20261017a.sh.tmp
mv /system/etc/x2v/x2v_product_boot_20261017a.sh.tmp /system/etc/x2v/x2v_product_boot_20261017a.sh
restorecon /system/etc/x2v/x2v_product_boot_20261017a.sh
echo OK
