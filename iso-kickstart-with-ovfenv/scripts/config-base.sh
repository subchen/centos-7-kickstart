#!/bin/bash -e

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

## disable NetworkManager
systemctl disable NetworkManager.service

## disable kdump
systemctl disable kdump.service
