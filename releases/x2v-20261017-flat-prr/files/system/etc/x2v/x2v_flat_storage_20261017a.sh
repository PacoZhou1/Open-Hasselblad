#!/system/bin/sh
# Same-filesystem publication; compressed RAW bytes are never copied/re-encoded.
# CLIPS and LIVE are supplied by the recording session/supervisor.
X2V_FILE_SYNC=${X2V_FILE_SYNC:-/system/bin/x2v_sync_paths_20261017a}
x2v_new_prr_dir() {
    mkdir -p "$CLIPS/.x2v-staging" "$CLIPS/.x2v-meta" || return 1
    xs_base=X2V_PRR_$(date +%Y%m%d_%H%M%S)
    xs_n=0
    while [ "$xs_n" -lt 1000 ]; do
        xs_id=$xs_base
        [ "$xs_n" = 0 ] || xs_id=${xs_base}_$xs_n
        if [ ! -e "$CLIPS/$xs_id.mov" ] && [ ! -e "$CLIPS/.x2v-meta/$xs_id.json" ] &&
           mkdir "$CLIPS/.x2v-staging/$xs_id" 2>/dev/null; then
            printf '%s\n' "$CLIPS/.x2v-staging/$xs_id"
            return 0
        fi
        xs_n=$((xs_n+1))
    done
    return 1
}
x2v_publish_prr() {
    xs_dir=$1; xs_id=${xs_dir##*/}
    case "$xs_dir" in "$CLIPS/.x2v-staging/"X2V_PRR_*) ;; *) return 2;; esac
    case "$xs_id" in *[!A-Za-z0-9_]*) return 2;; esac
    xs_mov=$CLIPS/$xs_id.mov; xs_meta=$CLIPS/.x2v-meta/$xs_id.json
    # Already published by an earlier stop request, or interrupted during cleanup.
    if [ -f "$xs_mov" ] && [ ! -e "$xs_dir/clip.mov" ] && [ -f "$xs_meta" ]; then
        "$X2V_FILE_SYNC" "$xs_meta" "$CLIPS/.x2v-meta" "$CLIPS" || return 6
        if [ -f "$xs_dir/clip.json" ]; then
            cmp -s "$xs_dir/clip.json" "$xs_meta" || return 4
            rm -f "$xs_dir/clip.json"
            rmdir "$xs_dir" 2>/dev/null || true
        fi
        printf '%s\n' "$xs_mov"; return 0
    fi
    [ -f "$xs_dir/clip.mov" ] && [ -f "$xs_dir/clip.json" ] || return 3
    [ ! -e "$xs_mov" ] || return 4
    IFS= read -r xs_json < "$xs_dir/clip.json" || return 3
    case "$xs_json" in *'"error":0}'*|*'"error":0,'*) ;; *) return 5;; esac
    mkdir -p "$CLIPS/.x2v-meta" || return 6
    # Metadata first, MOV last. A half-published entry never reaches the gallery.
    if [ -e "$xs_meta" ]; then
        cmp -s "$xs_dir/clip.json" "$xs_meta" || return 4
    else
        cp "$xs_dir/clip.json" "$xs_meta.pending" || return 6
        mv -n "$xs_meta.pending" "$xs_meta" || return 6
        [ ! -e "$xs_meta.pending" ] || return 4
    fi
    if [ -f "$LIVE/preview.ppm" ] && [ ! -e "$CLIPS/.x2v-meta/$xs_id.ppm" ]; then
        cp "$LIVE/preview.ppm" "$CLIPS/.x2v-meta/$xs_id.ppm" || true
    fi
    "$X2V_FILE_SYNC" "$xs_meta" "$CLIPS/.x2v-meta" || return 6
    mv -n "$xs_dir/clip.mov" "$xs_mov" || return 6
    [ ! -e "$xs_dir/clip.mov" ] && [ -f "$xs_mov" ] || return 4
    "$X2V_FILE_SYNC" "$xs_dir" "$CLIPS" || return 6
    # Remove only our redundant generated sidecar; never recurse into clip folders.
    rm -f "$xs_dir/clip.json"
    rmdir "$xs_dir" 2>/dev/null || true
    printf '%s\n' "$xs_mov"
}
