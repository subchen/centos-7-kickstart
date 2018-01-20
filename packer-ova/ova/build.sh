#!/bin/bash -e

CWD=$(cd $(dirname $0); pwd)

ovftool="/Applications/VMware OVF Tool/ovftool"

rm -f $CWD/centos7-disk1.vmdk
rm -f $CWD/centos7.ova
rm -f $CWD/centos7.ovf

VM_DISK_FILE=$CWD/centos7-disk1.vmdk

# virtualbox
cp -f $CWD/../output-*/*.vmdk $VM_DISK_FILE

# vmware-fusion compress disk
#vmware-vdiskmanager -t 5 -r $CWD/../output-*/*.vmdk $VM_DISK_FILE

#frep $CWD/centos7.ovf.tmpl --overwrite -e VM_DISK_SIZE=$(stat -c %s $VM_DISK_FILE 2>/dev/null || stat -f %z $VM_DISK_FILE)

frep $CWD/centos7.ovf.tmpl --overwrite -e CWD="$CWD"

"$ovftool" --skipManifestCheck --overwrite $CWD/centos7.ovf $CWD/centos7.ova
