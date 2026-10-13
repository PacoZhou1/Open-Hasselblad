"""Small diagnostic file transfer; bounded, exclusive paths, digest verified."""
import base64,hashlib,re

def upload(r,local,remote):
    data=local.read_bytes()
    if len(data)>256*1024:raise ValueError('Small-file transport limit')
    if not re.fullmatch(r'/tmp/x2v-native-20261011/[a-zA-Z0-9_.-]+',remote):raise ValueError('Not a diagnostic path')
    q=remote+'.b64'
    r.factory_shell('test ! -e '+remote+' && test ! -e '+q+' && (set -C; : >'+q+')')
    encoded=base64.b64encode(data).decode()
    for offset in range(0,len(encoded),140):
        r.factory_shell("printf '%s' '"+encoded[offset:offset+140]+"' >>"+q)
    r.factory_shell('base64 -d '+q+' >'+remote)
    digest=r.factory_shell('sha256sum '+remote).split()[0]
    if digest!=hashlib.sha256(data).hexdigest():raise RuntimeError('Transfer digest mismatch')
    r.factory_shell('rm '+q)
    return digest
