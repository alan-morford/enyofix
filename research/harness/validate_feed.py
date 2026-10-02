import os, sys, json, hashlib, re
F=sys.argv[1]; T=sys.argv[2] if len(sys.argv)>2 else 'org.webosarchive.v8fix'
txt=open(f'{F}/Packages',encoding='utf8').read()
st=[s for s in txt.split('\n\n') if s.strip()]
def parse(s):
    d={}
    for l in s.split('\n'):
        if ': ' in l or l.endswith(':'):
            k,_,v=l.partition(':'); d.setdefault(k,v.strip())
    return d
pk=[parse(s) for s in st]; bad=0
files=set(f for f in os.listdir(F) if f.endswith('.ipk'))
names=set(p['Filename'] for p in pk)
if files!=names: print('FILE MISMATCH', files^names); bad+=1
for p in pk:
    fn=f"{F}/{p['Filename']}"
    if hashlib.md5(open(fn,'rb').read()).hexdigest()!=p['MD5Sum'] or os.path.getsize(fn)!=int(p['Size']): print('MD5/SIZE BAD',p['Package']); bad+=1
    try: p['_src']=json.loads(p.get('Source','{}').replace("\\'","'"))
    except Exception as e: print('JSON BAD',p['Package'],e); bad+=1; p['_src']={}
seen={}
for p in pk:
    k=(p['Package'],p['Version'],p.get('Architecture'))
    if k in seen and seen[k]!=p['Filename']: print('DEDUPE TRAP',k); bad+=1
    seen[k]=p['Filename']
def vt(v): return [int(x) for x in re.findall(r'\d+',v)]
def newer(one,two): return vt(one)<vt(two)   # Preware versionNewer(one,two): one < two
def visible(p,ver,model,ignore):
    s=p['_src']; mn=s.get('MinWebOSVersion','1.0.0'); mx=s.get('MaxWebOSVersion','99.9.9')
    if newer(ver,mn): return False
    if not ignore:
        if newer(mx,ver): return False
        dc=s.get('DeviceCompatibility')
        if dc and model not in dc: return False
    return True
devs=[('TouchPad','3.0.5'),('TouchPad','3.1.0'),('Pre3','2.2.4'),('Veer','2.2.4'),('Veer','2.2.0'),('Pre2','2.2.4'),('Pre2','2.1.0'),('Pre','2.1.0'),('Pixi','2.1.0'),('Pre','1.4.5')]
for ignore in (False,True):
    print(f'ignoreDevices={"ON" if ignore else "OFF"}')
    for m,v in devs:
        vis={}
        for p in pk:
            if visible(p,v,m,ignore): vis.setdefault(p['Package'],p)
        missing=[]
        for p in vis.values():
            for d in [x.strip() for x in p.get('Depends','').split(',') if x.strip()]:
                if re.sub(r'\s*\(.*','',d) not in vis: missing.append(f"{p['Package']}->{d}")
        print(f'  {m:8s} {v}  {len(vis):3d} visible  v8fix={"YES" if T in vis else "-"}  deps {"OK" if not missing else "MISSING "+", ".join(missing)}')
print('stanzas',len(pk),'packages',len(set(p['Package'] for p in pk)),'problems',bad)
