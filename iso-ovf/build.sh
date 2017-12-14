#!/bin/bash -e

CWD=$(cd $(dirname $0); pwd)

docker run -it --rm \
    --privileged \
    -v $CWD/iso:/iso \
    centos:7 \
    /iso/build.sh /iso/CentOS-7-x86_64-Minimal-1708.iso


rm -f $CWD/ovf/*.iso

mv $CWD/iso/KS_*.iso $CWD/ovf/

$CWD/ovf/build.sh
