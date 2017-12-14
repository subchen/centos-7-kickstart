#!/bin/bash -e

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

CWD=$(cd $(dirname $0); pwd)

##############################################################
# Basic Configuration
##############################################################
echo "Configuring system ..."

## encoding
cat >> /etc/environment << EOF
LANG=en_US.UTF-8
LC_ALL=en_US.UTF-8
EOF

## timezone
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

## disable firewall and iptables
systemctl disable firewalld.service

## disable selinux
setenforce 0 || true
echo -e 'SELINUX=disabled\nSELINUXTYPE=targeted' > /etc/sysconfig/selinux

## disable kdump
systemctl disable kdump.service

## disable NetworkManager
systemctl disable NetworkManager.service
systemctl stop NetworkManager.service

## remove unused ifcfg
rm -f /etc/sysconfig/network-scripts/ifcfg-en*

## make 'eth0' the predictable network device
rm -f /etc/udev/rules.d/70*
ln -s /dev/null /etc/udev/rules.d/80-net-name-slot.rules || true

##############################################################
# Installing RPMs
##############################################################
echo "Installing RPMs ..."

## install rpms
yum -c $CWD/repo/iso.repo --disablerepo=* --enablerepo=iso-* \
    install -y open-vm-tools ovfenv-installer ntp ntpdate

## start ntpd
systemctl enable ntpd.service
systemctl start ntpd.service

##############################################################
# Updating Kernel
##############################################################
echo "Updating Kernel to 4.x ..."

yum -c $CWD/repo/iso.repo --disablerepo=* --enablerepo=iso-* \
    install -y kernel-ml

# remove kernel args
grubby --update-kernel=ALL --remove-args="rhgb quiet"

# set default kernel
kernel=$(rpm -ql kernel-ml | grep '^/boot/vmlinuz' | sort --version-sort | tail --lines=1)
grubby --set-default=$kernel
echo "Set Kernel as default: $kernel"

##############################################################
# Running ovfenv-installer for next reboot
##############################################################

cat >> /etc/rc.d/rc.local << EOF
ovfenv-installer --run-once --log-file=/var/log/ovfenv-installer.log
EOF

chmod +x /etc/rc.d/rc.local
