#!/bin/sh
# runapps.sh <pass> <listfile> [wait] : launch each app id in listfile, screenshot, save its log lines, close it
PASS=$1; LIST=$2; W=${3:-14}
B=/media/internal/pw2test/results/$PASS; mkdir -p $B
: > $B/summary.txt
closeapp() {
  for P in $(luna-send -n 1 palm://com.palm.applicationManager/running "{}" </dev/null | tr "{" "\n" | grep "\"id\": *\"$1\"" | sed -e "s/.*processid\": *\"\([0-9]*\)\".*/\1/" | sort -u); do
    luna-send -n 1 palm://com.palm.applicationManager/close "{\"processId\":\"$P\"}" </dev/null >/dev/null
  done
}
I=0
while read id params; do
  [ -z "$id" ] && continue
  I=$((I+1)); TAG=$(printf "%02d" $I)_$id
  luna-send -n 1 palm://com.palm.display/control/setState "{\"state\":\"on\"}" </dev/null >/dev/null
  N=$(wc -l < /var/log/messages)
  [ -z "$params" ] && params="{}"
  R=$(luna-send -n 1 palm://com.palm.applicationManager/launch "{\"id\":\"$id\",\"params\":$params}" </dev/null)
  sleep $W
  # close the USB storage popup (system UI windows other than the main one, 1000)
  for SP in $(luna-send -n 1 palm://com.palm.applicationManager/running "{}" </dev/null | tr "{" "\n" | grep '"com.palm.systemui"' | grep -o 'processid": *"[0-9]*' | grep -o '[0-9]*$'); do
    [ "$SP" != 1000 ] && luna-send -n 1 palm://com.palm.applicationManager/close "{\"processId\":\"$SP\"}" </dev/null >/dev/null
  done
  sleep 1
  luna-send -n 1 palm://com.palm.systemmanager/takeScreenShot "{\"file\":\"$B/$TAG.png\"}" </dev/null >/dev/null
  sleep 1
  M=$(wc -l < /var/log/messages); [ $M -lt $N ] && N=0
  tail -n +$((N+1)) /var/log/messages | grep -E "$id|LunaSysMgr.*(Uncaught|Error|error)" > $B/$TAG.log
  RUN=$(luna-send -n 1 palm://com.palm.applicationManager/running "{}" </dev/null | grep -c "\"$id\"")
  ERR=$(grep -cE "Uncaught|TypeError|ReferenceError|SyntaxError" $B/$TAG.log)
  echo "$TAG launch=$(echo $R | grep -q true && echo ok || echo FAIL) running=$RUN jserrors=$ERR" >> $B/summary.txt
  closeapp $id
  sleep 2
done < $LIST
echo DONE >> $B/summary.txt
