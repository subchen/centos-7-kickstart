#!/bin/bash -e

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

yum install -y epel-release

yum install -y \
    vim tmux wget curl zip unzip which \
    net-tools tree psmisc bind-utils \
    ntp ntpdate \
    git rsync \
    yajl \
    yum-utils createrepo \
    make automake autoconf libtool gcc gcc-c++ \
    sshpass the_silver_searcher jq

## start ntpd
systemctl enable ntpd.service
systemctl start ntpd.service

##############################################################
# Updating Kernel
##############################################################
echo "Updating Kernel to 4.x ..."

rpm -import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm
yum --enablerepo=elrepo-kernel install -y kernel-ml

# remove kernel args
grubby --update-kernel=ALL --remove-args="rhgb quiet"

# set default kernel
kernel=$(rpm -ql kernel-ml | grep '^/boot/vmlinuz' | sort --version-sort | tail --lines=1)
grubby --set-default=$kernel
echo "Set Kernel as default: $kernel"

##############################################################
# Running ovfenv-installer for next reboot
##############################################################
yum install -y https://github.com/subchen/ovfenv-installer/releases/download/v1.0.2/ovfenv-installer-1.0.2-17.x86_64.rpm

cat >> /etc/rc.d/rc.local << EOF
ovfenv-installer --run-once --log-file=/var/log/ovfenv-installer.log
EOF

chmod +x /etc/rc.d/rc.local
