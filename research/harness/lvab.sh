#!/bin/sh
D=/media/internal/pw2test; cd $D; rm -f diag-lv*.txt
for p in $(pidof node); do grep -q srv.js /proc/$p/cmdline && kill $p; done
(nohup node srv.js > srv.log 2>&1 < /dev/null &); sleep 2
CL() { for P in $(luna-send -n 1 palm://com.palm.applicationManager/running "{}" </dev/null | tr "{" "\n" | grep "com.palm.app.browser" | grep -o 'processid": *"[0-9]*' | grep -o '[0-9]*$'); do luna-send -n 1 palm://com.palm.applicationManager/close "{\"processId\":\"$P\"}" </dev/null >/dev/null; done; }
for v in index fixed; do
  CL; sleep 2
  luna-send -n 1 palm://com.palm.display/control/setState '{"state":"on"}' </dev/null >/dev/null
  luna-send -n 1 palm://com.palm.applicationManager/open "{\"id\":\"com.palm.app.browser\",\"params\":{\"target\":\"http://127.0.0.1:8123/lv/$v.html\"}}" </dev/null >/dev/null
  sleep 26
  for SP in $(luna-send -n 1 palm://com.palm.applicationManager/running "{}" </dev/null | tr "{" "\n" | grep '"com.palm.systemui"' | grep -o 'processid": *"[0-9]*' | grep -o '[0-9]*$'); do [ "$SP" != 1000 ] && luna-send -n 1 palm://com.palm.applicationManager/close "{\"processId\":\"$SP\"}" </dev/null >/dev/null; done
  sleep 1
  luna-send -n 1 palm://com.palm.systemmanager/takeScreenShot "{\"file\":\"$D/results/lv/br-$v.png\"}" </dev/null >/dev/null
done
CL
for p in $(pidof node); do grep -q srv.js /proc/$p/cmdline && kill $p; done
echo done > $D/results/lv/AB_DONE
