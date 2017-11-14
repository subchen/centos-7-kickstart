#!/bin/bash -e

CWD=$(cd $(dirname $0); pwd)

OVFTOOL="/Applications/VMware OVF Tool/ovftool"

# calc and replace iso size
ISO_FILE=$1
[ -z "$ISO_FILE" ] && ISO_FILE=$(echo $CWD/CentOS-*.iso)

if [ ! -f "$ISO_FILE" ]; then
    echo "file not found: $ISO_FILE"
    exit 1
fi

ISO_SIZE=$(stat -c %s $ISO_FILE 2>/dev/null || stat -f %z $ISO_FILE)
sed \
  -e "s#_ISO_FILE_#$ISO_FILE#g" \
  -e "s#_ISO_SIZE_#$ISO_SIZE#g" \
  $CWD/centos-7-kickstart.ovf.tmpl > $CWD/centos-7-kickstart.ovf


"$OVFTOOL" --skipManifestCheck --overwrite $CWD/centos-7-kickstart.ovf $CWD/centos-7-kickstart.ova
