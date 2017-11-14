#!/bin/bash -e

CWD=$(cd $(dirname $0); pwd)

echo "Updating Kernel to 4.x ..."
yum -c $CWD/repo/iso.repo --disablerepo=* --enablerepo=iso-* install -y kernel-ml

# remove kernel args
grubby --update-kernel=ALL --remove-args="rhgb quiet"

# set default kernel
kernel=$(rpm -ql kernel-ml | grep '^/boot/vmlinuz' | sort --version-sort | tail --lines=1)
grubby --set-default=$kernel
echo "Set Kernel as default: $kernel"
