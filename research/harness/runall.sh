#!/bin/sh
# runall.sh <pass> : run the Mojo/system, Enyo and web lists, then write results/<pass>/ALLDONE
P=$1; D=/media/internal/pw2test
mkdir -p $D/results/$P
grep -q always_full_compiler /etc/palm/browser.conf && echo flag=on > $D/results/$P/flag.txt || echo flag=off > $D/results/$P/flag.txt
# the local test page server (only ever kill our own node, never fork_server.js)
for p in $(pidof node); do grep -q srv.js /proc/$p/cmdline && kill $p; done
(cd $D && nohup node srv.js > srv.log 2>&1 < /dev/null &)
sleep 2
sh $D/runapps.sh $P/mojo $D/mojo.list 14
sh $D/runapps.sh $P/enyo $D/enyo.list 16
sh $D/runapps.sh $P/web $D/web.list 25
for p in $(pidof node); do grep -q srv.js /proc/$p/cmdline && kill $p; done
date > $D/results/$P/ALLDONE
