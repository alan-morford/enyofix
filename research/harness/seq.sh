#!/bin/sh
D=/media/internal/pw2test; rm -rf $D/results/mem; mkdir -p $D/results/mem
sh $D/pkgop.sh install upgrade
sh $D/memtest.sh on1
sh $D/pkgop.sh remove remove
md5sum /etc/palm/browser.conf >> $D/results/mem/pkg-remove.txt
sh $D/memtest.sh off1
sh $D/pkgop.sh install reinstall
sh $D/memtest.sh on2
luna-send -n 1 palm://com.palm.display/control/setProperty '{"timeout":60}' </dev/null >/dev/null
date > $D/results/mem/SEQDONE
