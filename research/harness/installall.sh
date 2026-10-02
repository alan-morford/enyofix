#!/bin/sh
# install every ipk in /media/internal/pw2test/ipks via the appinstaller, one at a time
cd /media/internal/pw2test/ipks
: > ../install.log
for f in *.ipk; do
  id=${f%.ipk}
  if [ -d /media/cryptofs/apps/usr/palm/applications/$id ]; then echo "$id already" >> ../install.log; continue; fi
  luna-send -i palm://com.palm.appinstaller/installNoVerify "{\"target\":\"/media/internal/pw2test/ipks/$f\",\"subscribe\":true}" </dev/null > /tmp/inst.out 2>&1 &
  P=$!; i=0
  while [ $i -lt 60 ]; do grep -qE "SUCCESS|FAILED|ERROR" /tmp/inst.out && break; sleep 2; i=$((i+1)); done
  kill $P 2>/dev/null
  echo "$id $(grep -oE '"status":"[A-Z_]+"' /tmp/inst.out | tail -1)" >> ../install.log
done
echo DONE >> ../install.log
