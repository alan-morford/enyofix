import os, sys, re
from PIL import Image, ImageDraw, ImageChops, ImageStat
R=sys.argv[1]; OUT=sys.argv[2]; os.makedirs(OUT, exist_ok=True)
def errs(p):
    if not os.path.exists(p): return []
    L=[]
    for l in open(p, errors='replace'):
        if re.search(r'Uncaught|TypeError|ReferenceError|SyntaxError', l):
            m=re.search(r'(Uncaught.*|\w+Error:.*)', l); L.append(re.sub(r'\d{4}-\d\d-\d\dT[\d:.]+Z \[\d+\] ','',(m.group(1) if m else l)).strip()[:160])
    return L
rows=[]
for grp in ('mojo','enyo','web'):
    names=sorted(f[:-4] for f in os.listdir(f'{R}/on/{grp}') if f.endswith('.png'))
    tiles=[]
    for n in names:
        a=f'{R}/off/{grp}/{n}.png'; b=f'{R}/on/{grp}/{n}.png'
        try:
            ia=Image.open(a).convert('RGB'); ib=Image.open(b).convert('RGB')
            d=ImageStat.Stat(ImageChops.difference(ia.crop((0,30,320,480)), ib.crop((0,30,320,480)))).mean
            diff=sum(d)/3
        except Exception as e:
            ia=ib=None; diff=-1
        eo=errs(f'{R}/off/{grp}/{n}.log'); en=errs(f'{R}/on/{grp}/{n}.log')
        rows.append((grp,n,round(diff,1),len(eo),len(en),sorted(set(en)-set(eo)),sorted(set(eo)-set(en))))
        tiles.append((n,ia,ib))
    # contact sheets: 4 apps per row, each tile = off|on at half size
    W,H=160,240; per=4
    for k in range(0,len(tiles),12):
        chunk=tiles[k:k+12]; rowsN=(len(chunk)+per-1)//per
        sheet=Image.new('RGB',(per*(2*W+12),rowsN*(H+16)),'white'); dr=ImageDraw.Draw(sheet)
        for i,(n,ia,ib) in enumerate(chunk):
            x=(i%per)*(2*W+12); y=(i//per)*(H+16)
            dr.text((x+2,y+1), n[:46], fill='black')
            for j,im in enumerate((ia,ib)):
                if im: sheet.paste(im.resize((W,H)),(x+j*W,y+14))
        sheet.save(f'{OUT}/{grp}-{k//12+1}.png')
for r in rows:
    print('\t'.join(map(str,r[:5])), '| NEW-with-flag:', r[5] or '-', '| GONE-with-flag:', r[6] or '-')
