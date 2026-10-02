#!/bin/sh
# memtest.sh <label> : restart Luna, run a fixed app workload, record LunaSysMgr memory/CPU
L=$1; D=/media/internal/pw2test/results/mem; mkdir -p $D; O=$D/$L.txt
stop LunaSysMgr; sleep 3; start LunaSysMgr; sleep 70
luna-send -n 1 palm://com.palm.display/control/setProperty '{"timeout":1800}' </dev/null >/dev/null
P=$(pidof LunaSysMgr | tr " " "\n" | sort -n | head -1)
rss() { grep -E "^(VmRSS|VmHWM)" /proc/$P/status | tr -s " \t" " " | tr "\n" " "; }
cpu() { awk '{print $14+$15}' /proc/$P/stat; }
{ echo "label=$L flag=$(grep -c always_full /etc/palm/browser.conf)"; echo "idle: $(rss) MemFree=$(grep MemFree /proc/meminfo | tr -s ' ')"; } > $O
c0=$(cpu); t0=$(date +%s)
for a in com.palm.app.email com.palm.app.contacts com.palm.app.messaging com.palm.app.calendar com.palm.app.preware2 org.webosinternals.preware com.choorp.dash-weather com.palm.app.browser; do
  luna-send -n 1 palm://com.palm.display/control/setState '{"state":"on"}' </dev/null >/dev/null
  luna-send -n 1 palm://com.palm.applicationManager/launch "{\"id\":\"$a\"}" </dev/null >/dev/null
  sleep 20
  echo "after $a: $(rss)" >> $O
done
echo "luna_cpu_ticks_workload=$(( $(cpu) - c0 )) over $(( $(date +%s) - t0 ))s" >> $O
echo "end: MemFree=$(grep MemFree /proc/meminfo | tr -s ' ') swapused=$(free | awk '/Swap/{print $3}')" >> $O
for a in com.palm.app.email com.palm.app.contacts com.palm.app.messaging com.palm.app.calendar com.palm.app.preware2 org.webosinternals.preware com.choorp.dash-weather com.palm.app.browser; do
  for PP in $(luna-send -n 1 palm://com.palm.applicationManager/running "{}" </dev/null | tr "{" "\n" | grep "\"$a\"" | grep -o 'processid": *"[0-9]*' | grep -o '[0-9]*$'); do luna-send -n 1 palm://com.palm.applicationManager/close "{\"processId\":\"$PP\"}" </dev/null >/dev/null; done
done
echo DONE >> $O
