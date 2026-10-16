from pathlib import Path
import json,shutil
D=Path(__file__).resolve().parent
s=(D/'installed-supervisor.sh').read_text()
a=s.index('set_profile() { case');b=s.index('start_job() {',a)
s=s[:a]+'''FPS=24
profile_decode() {
    case "$1" in
        raw_3920_2946_24) CODEC=prores_raw; FPS=24;;
        raw_3920_2946_25) CODEC=prores_raw; FPS=25;;
        raw_3920_2946_30) CODEC=prores_raw; FPS=30;;
        dng_3888_2912_24) CODEC=dng; FPS=24;;
        h264_1300_970_24) CODEC=h264; FPS=24;;
        *) return 1;;
    esac
    PROFILE=$1
}
case "$CODEC" in h264) PROFILE=h264_1300_970_24;; dng) PROFILE=dng_3888_2912_24;; *) PROFILE=raw_3920_2946_24;; esac
saved_profile=""; [ -f "$PROD/profile" ] && read saved_profile < "$PROD/profile"
profile_decode "$saved_profile" || profile_decode "$PROFILE"
choose_profile() {
    profile_decode "$1" || return 1
    printf '%s\\n' "$PROFILE" > "$PROD/profile.tmp" && mv -f "$PROD/profile.tmp" "$PROD/profile" || return 1
    printf '%s\\n' "$CODEC" > "$PROD/codec.tmp" && mv -f "$PROD/codec.tmp" "$PROD/codec"
    LAST=""; DETAIL=""; ENTER_FAILS=0; ENTER_AT=0
    log "profile $PROFILE fps=$FPS"
}
set_codec() {
    case "$1" in
        prores_raw) choose_profile raw_3920_2946_24;;
        dng) choose_profile dng_3888_2912_24;;
        h264) choose_profile h264_1300_970_24;;
    esac
}
''' +s[b:]
s=s.replace('    sf state; S_ST=$SF','    ACTIVE_FPS=24\n    [ -f "$LIVE/fps" ] && read ACTIVE_FPS < "$LIVE/fps"\n    sf state; S_ST=$SF')
s=s.replace('X2V_GUI_MODE=overlay sh "$SESSION"','X2V_FPS=$FPS X2V_GUI_MODE=overlay sh "$SESSION"')
s=s.replace('start) [ "$DESIRED" = video ]','start) [ "$ACTIVE_FPS" = "$FPS" ] && [ "$DESIRED" = video ]')
s=s.replace('        codec_prores_raw|codec_h264|codec_dng)', '''        profile_*)
               [ -z "$JOB" ] && [ "$S_ST" != recording ] && [ "$S_ST" != finalizing ] && choose_profile "${cmd#profile_}";;
        codec_prores_raw|codec_h264|codec_dng)''')
s=s.replace('        video:down) now;', '''        video:up) [ "$ACTIVE_FPS" = "$FPS" ] || { [ "$st" = idle -o "$st" = error ] && start_job exit; };;
        video:down) now;''')
s=s.replace('[ "$s" = up ] && [ -z "$JOB_KIND" -o', '[ "$s" = up ] && [ "$ACTIVE_FPS" = "$FPS" ] && [ -z "$JOB_KIND" -o')
s=s.replace('    secs=0; gen=0; frames=0','    [ "$DESIRED" = video ] && [ "$ACTIVE_FPS" != "$FPS" ] && [ "$JOB_KIND" != exit ] && phase=entering\n    secs=0; gen=0; frames=0')
(D/'supervisor.sh').write_text(s)
s=(D/'installed-session.sh').read_text()
a=s.index('SERVICE=/system/bin/camera-service')
selectors='''FPS=${X2V_FPS:-24}
ADAPTER=mode21-c-24fps; GRAPH=mode21-c24; RESIDENT=GROUP13_MODE21C24_PRR_RESIDENT_V1
case "$FPS" in
 24) ;;
'''
for fps,name in [(25,'C25'),(30,'D30')]:
 r=json.loads((D/f'candidate-{fps}.json').read_text())
 selectors+=f''' {fps})
    LIB=/system/lib64/libx2v_af_{fps}_20261016.so
    LIB_SHA={r['lib_sha']}
    CONF=$ETC/x2v_af_{fps}_20261016.conf
    CONF_SHA={r['conf_sha']}
    VIEW=isp
    ADAPTER=mode21-{name[0].lower()}-{fps}fps; GRAPH=mode21-{name.lower()}; RESIDENT=GROUP13_MODE21{name}_PRR_AF_V1;;
'''
selectors+=' *) echo invalid_fps >&2; exit 2;;\nesac\n'
s=s[:a]+selectors+s[a:]
s=s.replace('export XDG_RUNTIME_DIR=/tmp X2V_SOURCE_ADAPTER=mode21-c-24fps X2V_OWNED_RAW_GRAPH=mode21-c24','export XDG_RUNTIME_DIR=/tmp X2V_SOURCE_ADAPTER=$ADAPTER X2V_OWNED_RAW_GRAPH=$GRAPH').replace('export X2V_RESIDENT=GROUP13_MODE21C24_PRR_RESIDENT_V1','export X2V_RESIDENT=$RESIDENT')
s=s.replace('    echo up > "$LIVE/session"','    echo "$FPS" > "$LIVE/fps"\n    echo up > "$LIVE/session"')
# Diagnostic pause survives graph changes, so failed near AF does not fight the user's ring.
s=s.replace('video_af_start() {','video_af_start() {\n    [ -f "$HOME_DIR/af-diagnostic-pause" ] && return 0')
assert 'af-diagnostic-pause' in s
(D/'session.sh').write_text(s)
s=(D/'installed-profiles.qml').read_text();s=s.replace('    // ProRes RAW / CinemaDNG 只有 24 是接通的，菜单不提供 25/30。','    // ProRes RAW: C24 / C25 / D30 qualified from source timestamps; DNG remains 24.')
a=s.index('        {id: "dng_')
s=s[:a]+''.join(f'        {{id: "raw_3920_2946_{fps}", codec: "prores_raw", raw: true, width: 3888, height: 2912, fps: {fps}, format: "ProRes RAW HQ", bitrate: "随画面变化", bits: "", opengate: true, available: true, verifiedLabel: "切换中"}},\n' for fps in [25,30])+s[a:]
(D/'RecordingProfiles.qml').write_text(s)
s=(D.parent/'video-afc-continuous-20261016/button-fix/gui/main.qml').read_text();assert 'root.writeCmd("codec_" + p.codec);' in s
s=s.replace('root.writeCmd("codec_" + p.codec);','root.writeCmd("profile_" + p.id);')
(D/'main.qml').write_text(s)
