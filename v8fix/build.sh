#!/bin/bash
# Build org.webosarchive.v8fix as an installable .ipk -> ./bin/
# Layout: debian-binary control.tar.gz data.tar.gz pmPostInstall.script pmPreRemove.script
# (the pm*.script copies are what the Palm App Installer / WebOS Quick Install runs).
set -e
cd "$(dirname "$0")"
ID=$(sed -n 's/^Package: //p' control/control)
VER=$(sed -n 's/^Version: //p' control/control)
ARCH=$(sed -n 's/^Architecture: //p' control/control)
OUT=bin/${ID}_${VER}_${ARCH}.ipk
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT

mkdir -p "$T/c" "$T/d/usr/palm/applications/$ID"
cp control/control "$T/c/"
cp control/postinst control/prerm "$T/c/"
chmod 644 "$T/c/control"
chmod 755 "$T/c/postinst" "$T/c/prerm"
cp data/README "$T/d/usr/palm/applications/$ID/"
chmod 644 "$T/d/usr/palm/applications/$ID/README"

# scripts must have unix line endings, this folder lives on a Windows drive
sed -i 's/\r$//' "$T/c/"*

(cd "$T/c" && tar --owner=0 --group=0 -czf ../control.tar.gz ./control ./postinst ./prerm)
(cd "$T/d" && tar --owner=0 --group=0 -czf ../data.tar.gz .)
echo "2.0" > "$T/debian-binary"
cp "$T/c/postinst" "$T/pmPostInstall.script"
cp "$T/c/prerm" "$T/pmPreRemove.script"

mkdir -p bin
rm -f "$OUT"
(cd "$T" && ar rc pkg.ipk debian-binary control.tar.gz data.tar.gz pmPostInstall.script pmPreRemove.script)
cp "$T/pkg.ipk" "$OUT"
echo "built $OUT ($(stat -c %s "$OUT") bytes, md5 $(md5sum "$OUT" | cut -d' ' -f1))"
