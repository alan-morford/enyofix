import os, io, tarfile, re, json
exec(open('classify.py').read().split('res=[]')[0])
out=[]
for f in sorted(os.listdir('ipks')):
    try:
        files={}
        for name,body in members('ipks/'+f):
            if name.startswith('data.tar'):
                t=tarfile.open(fileobj=io.BytesIO(body))
                for m in t.getmembers():
                    if m.isfile() and '/applications/' in m.name and re.search(r'(index\.html|appinfo\.json|enyo\.js|depends\.js|package\.js)$', m.name):
                        files[m.name]=t.extractfile(m).read().decode('utf8','replace')
        ai=[n for n in files if n.endswith('/appinfo.json')]
        if not ai: continue
        root=min(ai,key=len).rsplit('/',1)[0]
        try: info=json.loads(files[root+'/appinfo.json'])
        except Exception: info={}
        idx=files.get(root+'/'+info.get('main','index.html'),'')
        srcs=re.findall(r'<script[^>]+src=["\']([^"\']+)', idx)
        kind='mojo' if any('mojo' in s for s in srcs) else 'other'
        ver=''
        if any('frameworks/enyo' in s for s in srcs): kind='enyo1'; ver=next(s for s in srcs if 'frameworks/enyo' in s)
        elif any(re.search(r'enyo\.js$', s) for s in srcs):
            kind='enyo2'
            for n,c in files.items():
                if n.startswith(root) and n.endswith('enyo.js'):
                    m=re.search(r'enyo\.version\s*=\s*\{[^}]*?enyo\s*:\s*"([^"]+)"|version:\s*"(2\.[0-9][^"]*)"|enyo\s*:\s*"(2\.[0-9][^"]*)"', c)
                    if m: ver=[g for g in m.groups() if g][0]; break
        out.append((kind, info.get('id',f[:-4]), info.get('title',''), info.get('version',''), ver))
    except Exception as e: pass
from collections import Counter
print(Counter(o[0] for o in out))
for o in out:
    if o[0].startswith('enyo'): print('\t'.join(map(str,o)))
