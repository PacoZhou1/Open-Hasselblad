"""Shared single-camera reservation. No device access; no automatic expiry."""
import argparse
import datetime
import json
from pathlib import Path

R=Path(__file__).resolve().parents[1]
LOCK=R/'local-verification/camera-testing.lock'
NOTICE=R/'TESTING.md'
REQUESTS=R/'local-verification/camera-testing-requests'

def pending():
    if not REQUESTS.exists():return []
    return [json.loads(p.read_text()) for p in sorted(REQUESTS.glob('*.json'))]

def notice_requests():
    items=pending()
    if not items:return
    with NOTICE.open('a') as f:
        f.write('\n## Pending camera work / 等待实机\n')
        for item in items:f.write('\n- '+item['owner']+': '+item['task']+'\n')
        f.write('\n完成当前短测并确认恢复后，请先释放占用再做离线分析/编译，让等待者领取；无自动抢锁。\n')

def now():return datetime.datetime.now().astimezone().isoformat()

def main():
    p=argparse.ArgumentParser(description=__doc__)
    s=p.add_subparsers(dest='action',required=True)
    s.add_parser('status')
    q=s.add_parser('request');q.add_argument('owner');q.add_argument('task')
    c=s.add_parser('claim');c.add_argument('owner');c.add_argument('task')
    u=s.add_parser('update');u.add_argument('owner');u.add_argument('task')
    f=s.add_parser('release');f.add_argument('owner');f.add_argument('report',type=Path)
    a=p.parse_args()
    if a.action=='request':
        assert a.owner and all(c.isalnum() or c in '_-' for c in a.owner)
        REQUESTS.mkdir(exist_ok=True)
        request=dict(owner=a.owner,task=a.task,requested_at=now())
        (REQUESTS/(a.owner+'.json')).write_text(json.dumps(request,ensure_ascii=False)+'\n')
        notice_requests();print(json.dumps(request,ensure_ascii=False));return
    if a.action=='status':
        d=json.loads((LOCK/'owner.json').read_text()) if LOCK.exists() else {'state':'available'}
        d['waiting']=pending();print(json.dumps(d,ensure_ascii=False));return
    if a.action=='claim':
        try:LOCK.mkdir()
        except FileExistsError:raise SystemExit('BUSY: read TESTING.md; do not start camera commands')
        (REQUESTS/(a.owner+'.json')).unlink(missing_ok=True)
        d=dict(state='TESTING',owner=a.owner,task=a.task,claimed_at=now(),updated_at=now())
    else:
        d=json.loads((LOCK/'owner.json').read_text())
        assert d['owner']==a.owner,'Another operator owns the camera'
        if a.action=='release':
            report=json.loads(a.report.read_text())
            assert report.get('recovery_rc')=='0' and report.get('locks_absent') is True,'Actual restored report required; failure holds ownership'
            d.update(state='available',released_at=now(),recovery_report=str(a.report.resolve()))
            archive=R/'local-verification'/('camera-testing-release-'+datetime.datetime.now().strftime('%Y%m%d-%H%M%S')+'.json')
            archive.write_text(json.dumps(d,indent=2,ensure_ascii=False)+'\n')
            NOTICE.write_text('# Camera available / 相机空闲\n\nLast operator: '+a.owner+'\n\nRestored evidence: '+str(a.report.resolve())+'\n\nBefore any camera command, claim with `python3 local-verification/camera_testing.py claim OWNER TASK`. No automatic lock expiry.\n')
            (LOCK/'owner.json').unlink();LOCK.rmdir();notice_requests();d['waiting']=pending();print(json.dumps(d,ensure_ascii=False));return
        d.update(task=a.task,updated_at=now())
    (LOCK/'owner.json').write_text(json.dumps(d,indent=2,ensure_ascii=False)+'\n')
    NOTICE.write_text('# TESTING — 相机正在被占用\n\n**Operator / 操作者：'+d['owner']+'**\n\n任务：'+d['task']+'\n\n更新：'+d['updated_at']+'\n\n其他代理不得运行 ADB、USB、factory、录制、重启或装机命令。离线代码与文件分析可继续。占用无自动超时；只有操作者完成停止和原厂恢复后释放。原始数据保留，不刷启动/固件分区。\n\n状态：`python3 local-verification/camera_testing.py status`\n\n释放：`python3 local-verification/camera_testing.py release '+d['owner']+' RESTORED_REPORT.json`\n')
    notice_requests();d['waiting']=pending();print(json.dumps(d,ensure_ascii=False))

if __name__=='__main__':main()
