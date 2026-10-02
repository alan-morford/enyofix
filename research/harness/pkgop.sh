#!/bin/sh
# pkgop.sh install|remove <label> : drive Preware's ipkgservice like Preware does
D=/media/internal/pw2test; O=$D/results/mem/pkg-$2.txt; mkdir -p $D/results/mem
if [ "$1" = install ]; then
  for p in $(pidof node); do grep -q srv.js /proc/$p/cmdline && kill $p; done
  (cd $D && nohup node srv.js > srv.log 2>&1 < /dev/null &); sleep 2
  luna-send -i palm://org.webosinternals.ipkgservice/install '{"filename":"org.webosarchive.v8fix_1.0.1_all.ipk","url":"http://127.0.0.1:8123/org.webosarchive.v8fix_1.0.1_all.ipk"}' </dev/null > $O 2>&1 &
else
  luna-send -i palm://org.webosinternals.ipkgservice/remove '{"package":"org.webosarchive.v8fix"}' </dev/null > $O 2>&1 &
fi
K=$!; i=0; while [ $i -lt 60 ]; do grep -qE '"stage": *"(completed|failed)"' $O && break; sleep 2; i=$((i+1)); done; kill $K
for p in $(pidof node); do grep -q srv.js /proc/$p/cmdline && kill $p; done
{ echo "flag lines: $(grep -c always_full /etc/palm/browser.conf)"; grep -n '^Flags=' /etc/palm/browser.conf; ls /etc/palm | grep browser.conf; grep -A3 'Package: org.webosarchive.v8fix' /media/cryptofs/apps/usr/lib/ipkg/status | grep Version; } >> $O
echo PKGDONE >> $O
