#!/system/bin/sh
# X2V firmware payload installer (camera domain, root).
#   install <stage>  copy the manifest's files into /system (never over a different file) and the GUI payload
#   hook <stage>     make weston load the boot module; retire the old init services
#   unhook           put the stock weston.ini back (the camera then boots fully stock)
#   status           print what is installed
PATH=/sbin:/system/sbin:/system/bin:/system/xbin
set -u
ROOT=/blackbox/x2v-native-20261011
PROD=$ROOT/product
ETC=/system/etc/x2v
INI=/system/etc/weston.ini
STOCK_INI_SHA=879b0395a612949357aa08a3804e0805123115b895c059e0851099bd341adfcf
HOOK_INI_SHA=@HOOK_INI_SHA@

sha() { sha256sum "$1" 2>/dev/null | cut -d' ' -f1; }
die() { echo "FAIL $*"; exit 1; }
rw() { mount -o remount,rw /system || die remount_rw; }
ro() { mount -o remount,ro /system; grep -q ' /system ext4 ro,' /proc/mounts || echo "WARN system_not_ro"; }

install() {
    st=$1
    [ -f "$st/manifest" ] || die no_manifest
    # Every staged file must match the manifest before anything is touched.
    while read h mode dest src; do
        [ "$(sha "$st/$src")" = "$h" ] || die "stage_sha $src"
        if [ -e "$dest" ] && [ "$(sha "$dest")" != "$h" ]; then die "exists_different $dest"; fi
    done < "$st/manifest"
    rw
    mkdir -p "$ETC" && chmod 755 "$ETC"
    while read h mode dest src; do
        [ -e "$dest" ] && { echo "same $dest"; continue; }
        cp "$st/$src" "$dest.x2vtmp" && chmod "$mode" "$dest.x2vtmp" && mv "$dest.x2vtmp" "$dest" || { ro; die "copy $dest"; }
        echo "installed $dest"
    done < "$st/manifest"
    sync; ro
    while read h mode dest src; do [ "$(sha "$dest")" = "$h" ] || die "verify $dest"; done < "$st/manifest"
    # GUI payload is data: keep the first copy that was there as the rollback point.
    mkdir -p "$PROD/backup"
    [ -d "$PROD/backup/gui-before-product" ] || cp -r "$ROOT/gui" "$PROD/backup/gui-before-product"
    cp "$st"/gui/* "$ROOT/gui/" || die gui_copy
    for f in "$st"/gui/*; do [ "$(sha "$f")" = "$(sha "$ROOT/gui/${f##*/}")" ] || die "gui_verify ${f##*/}"; done
    echo "OK install"
}

hook() {
    st=$1
    [ "$(sha "$st/weston.ini.hook")" = "$HOOK_INI_SHA" ] || die hook_ini_sha
    cur=$(sha "$INI")
    [ "$cur" = "$HOOK_INI_SHA" ] && { echo "OK already_hooked"; return 0; }
    [ "$cur" = "$STOCK_INI_SHA" ] || die "weston_ini_unknown $cur"
    mkdir -p "$PROD/backup"; cp "$INI" "$PROD/backup/weston.ini.stock"
    rw
    [ -f "$ETC/weston.ini.stock" ] || cp "$INI" "$ETC/weston.ini.stock"
    mkdir -p "$ETC/retired"
    for rc in x2v-prr-gui.rc x2v-prr-rec.rc; do
        [ -f "/system/etc/init/$rc" ] && mv "/system/etc/init/$rc" "$ETC/retired/$rc" && echo "retired $rc"
    done
    cp "$st/weston.ini.hook" "$INI.x2vtmp" && chmod 644 "$INI.x2vtmp" && mv "$INI.x2vtmp" "$INI" || { ro; die ini_copy; }
    sync; ro
    [ "$(sha "$INI")" = "$HOOK_INI_SHA" ] || die ini_verify
    echo "OK hook"
}

unhook() {
    [ "$(sha "$ETC/weston.ini.stock")" = "$STOCK_INI_SHA" ] || die stock_copy_missing
    [ "$(sha "$INI")" = "$STOCK_INI_SHA" ] && { echo "OK already_stock"; return 0; }
    rw
    cp "$ETC/weston.ini.stock" "$INI.x2vtmp" && chmod 644 "$INI.x2vtmp" && mv "$INI.x2vtmp" "$INI" || { ro; die ini_copy; }
    sync; ro
    [ "$(sha "$INI")" = "$STOCK_INI_SHA" ] || die ini_verify
    echo "OK unhook"
}

status() {
    i=$(sha "$INI")
    case "$i" in $STOCK_INI_SHA) echo "weston.ini stock";; $HOOK_INI_SHA) echo "weston.ini hooked";; *) echo "weston.ini unknown $i";; esac
    ls -lZ "$ETC" /system/lib64/weston 2>&1
    [ -f "$PROD/disable" ] && echo "product disabled"
    cat /tmp/x2v-product/state.json 2>/dev/null
}

case "${1:-}" in
    install) install "${2:?stage}";;
    hook) hook "${2:?stage}";;
    unhook) unhook;;
    status) status;;
    *) echo "usage: install <stage>|hook <stage>|unhook|status"; exit 2;;
esac
