#!/bin/bash -e

CWD=$(cd $(dirname $0); pwd)

# >> Method 1
# %post --nochroot --log=/mnt/sysimage/root/nochroot-install.log
# # cdrom: /dev/sr0 -> /run/install/repo/
# # /mnt/install -> /run/install
# cp -rf -v /run/install/repo/scripts /mnt/sysimage/tmp/
# %end

# >> Method 2
# %post --interpreter=/bin/bash --log=/root/install.log
# mkdir -p /mnt/cdrom
# mount /dev/sr0 /mnt/cdrom
# bash -e /mnt/cdrom/scripts/install.sh
# umount /mnt/cdrom
# %end

$CWD/ovfenv-install.sh
$CWD/config-base.sh
$CWD/config-networking.sh
$CWD/config-hostname.sh
$CWD/config-dns.sh
$CWD/config-ntp.sh
$CWD/update-kernel.sh
