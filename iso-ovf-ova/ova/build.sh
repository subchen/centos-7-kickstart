#!/bin/bash -e

CWD=$(cd $(dirname $0); pwd)

DISK_FILE=$CWD/centos-7-kickstart-disk1.vmdk

cp -f $CWD/exported/*.vmdk $DISK_FILE

DISK_SIZE=$(stat -c %s $DISK_FILE 2>/dev/null || stat -f %z $DISK_FILE)

sed -e "s#_DISK_SIZE_#$DISK_SIZE#g" \
  $CWD/centos-7-kickstart.ovf.tmpl > $CWD/centos-7-kickstart.ovf
