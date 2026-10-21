from pathlib import Path
D=Path(__file__).resolve().parent;R=D.parents[1]
base=R/'releases/x2v-20261016-af-focuspoint/files/system/etc/x2v'
def rep(s,a,b):
 assert a in s,a
 return s.replace(a,b)
helper='/system/etc/x2v/x2v_flat_storage_20261017a.sh'
s=(base/'x2v_video_session_20261014zl.sh').read_text()
s=rep(s,'CLIPS=/mnt/media_rw/ssd/X2V_RAW','CLIPS=/mnt/media_rw/ssd/X2V_RAW\n. '+helper)
s=rep(s,'    d=$CLIPS/X2V_${p}_$(date +%Y%m%d_%H%M%S)\n    mkdir -p "$d" || return 4', '''    if [ "$p" = PRR ]; then
        d=$(x2v_new_prr_dir) || return 4
    else
        d=$CLIPS/X2V_${p}_$(date +%Y%m%d_%H%M%S)
        mkdir -p "$d" || return 4
    fi''')
s=rep(s,'    status_field last_clip\n}', '''    c=$(status_field last_clip)
    case "$c" in
        "$CLIPS/.x2v-staging/"X2V_PRR_*) x2v_publish_prr "$c";;
        *) printf '%s\\n' "$c";;
    esac
}''')
(D/'session.sh').write_text(s)
s=(base/'x2v_product_boot_20261015c.sh').read_text()
s=rep(s,'SESSION=$ETC/x2v_video_session_20261014zl.sh','SESSION=$ETC/x2v_video_session_20261017flat.sh')
s=rep(s,'catalog_add "${c##*/}"','clip_id=${c##*/}; clip_id=${clip_id%.mov}\n                catalog_add "$clip_id"')
a=s.index('    case "$1" in\n        X2V_H264_',s.index('catalog_entry()'))
b=s.index('    [ -f "$j" ]',a)
s=s[:a]+'''    j=$CLIPS/$1/clip.json
    th=$CLIPS/$1/thumb.ppm
    case "$1" in
        X2V_H264_*) m=$CLIPS/$1/clip.mp4; w=1300; h=970; f=H.264;;
        X2V_DNG_*) m=$CLIPS/$1/proxy.mp4; w=3888; h=2912; f=CinemaDNG;;
        *)
            w=3888; h=2912; f="ProRes RAW"
            if [ -f "$CLIPS/$1.mov" ]; then
                m=$CLIPS/$1.mov; j=$CLIPS/.x2v-meta/$1.json; th=$CLIPS/.x2v-meta/$1.ppm
            else
                m=$CLIPS/$1/clip.mov
            fi;;
    esac
'''+s[b:]
s=rep(s,'    th=""; [ -f "$CLIPS/$1/thumb.ppm" ] && th=$CLIPS/$1/thumb.ppm','    [ -f "$th" ] || th=""')
s=rep(s,"grep -E '^X2V_(PRR|H264|DNG)_' | sed", "grep -E '^X2V_(PRR|H264|DNG)_' | sed 's/\\.mov$//' | sort -u | sed")
(D/'supervisor.sh').write_text(s)
print('Flat MOV publication + old/new catalog compatibility prepared')
