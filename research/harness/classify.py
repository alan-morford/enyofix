import os, sys, io, tarfile, re, json
def members(path):
    data=open(path,'rb').read()
    if data[:8]==b'!<arch>\n':
        i=8
        while i<len(data):
            name=data[i:i+16].decode().strip().rstrip('/'); size=int(data[i+48:i+58]); body=data[i+60:i+60+size]
            yield name, body; i+=60+size+(size&1)
    else:
        t=tarfile.open(fileobj=io.BytesIO(data))
        for m in t.getmembers():
            if m.isfile(): yield os.path.basename(m.name), t.extractfile(m).read()
res=[]
for f in sorted(os.listdir('ipks')):
    try:
        files={}
        for name,body in members('ipks/'+f):
            if name.startswith('data.tar'):
                t=tarfile.open(fileobj=io.BytesIO(body))
                for m in t.getmembers():
                    if m.isfile() and re.search(r'\.(js|html|json)$', m.name) and m.size<3_000_000:
                        files[m.name]=t.extractfile(m).read().decode('utf8','replace')
        apps=[n for n in files if n.endswith('appinfo.json') and '/applications/' in n]
        appinfo={}
        if apps:
            try: appinfo=json.loads(re.sub(r'//.*','',files[apps[0]]))
            except Exception: pass
        alljs='\n'.join(files.values())
        kind='other'
        if re.search(r'frameworks/enyo/', alljs) or re.search(r'enyo/1\.0/framework', alljs): kind='enyo1'
        if re.search(r'enyo\.version|enyo\.kind\(', alljs):
            m=re.search(r'enyo\.version\s*[=:.]\s*\{?[^}]{0,80}', alljs)
            if kind!='enyo1' or re.search(r'"?enyo"?\s*:\s*"2', alljs): kind = 'enyo2' if kind!='enyo1' else kind
        if kind=='other' and re.search(r'Mojo\.', alljs): kind='mojo'
        if kind=='other' and appinfo.get('type')=='pdk': kind='pdk'
        ver=''
        m=re.search(r'enyo\.version\s*=\s*\{[^}]*?enyo\s*:\s*"([^"]+)"|enyo:\s*"(2\.[0-9][^"]*)"', alljs)
        if m: ver=m.group(1) or m.group(2)
        res.append((kind, f[:-4], appinfo.get('title',''), appinfo.get('uiRevision',''), ver))
    except Exception as e:
        res.append(('error', f[:-4], str(e)[:40], '', ''))
from collections import Counter
print(Counter(r[0] for r in res))
for r in res:
    if r[0] in ('enyo1','enyo2'): print('\t'.join(map(str,r)))
