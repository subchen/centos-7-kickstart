#!/bin/bash -e

CWD=$(cd $(dirname $0); pwd)

echo "Configuring Networking ..."

# eth0
export IP0=$($CWD/bin/ovfenv-get.sh ip0)
export GATEWAY0=$($CWD/bin/ovfenv-get.sh gateway0)
export SUBNET0=$($CWD/bin/ovfenv-get.sh subnet0)

if [ -z "$IP0" ]; then
    cp -f $CWD/conf/ifcfg-eth0.dhcp /etc/sysconfig/network-scripts/ifcfg-eth0
else
    $CWD/bin/frep $CWD/conf/ifcfg-eth0.static.gotmpl:/etc/sysconfig/network-scripts/ifcfg-eth0 --overwrite
fi

# eth1
export IP1=$($CWD/bin/ovfenv-get.sh ip1)
export GATEWAY1=$($CWD/bin/ovfenv-get.sh gateway1)
export SUBNET1=$($CWD/bin/ovfenv-get.sh subnet1)

if [ -z "$IP1" ]; then
    cp -f $CWD/conf/ifcfg-eth1.dhcp /etc/sysconfig/network-scripts/ifcfg-eth1
else
    $CWD/bin/frep $CWD/conf/ifcfg-eth1.static.gotmpl:/etc/sysconfig/network-scripts/ifcfg-eth1 --overwrite
fi

# remove others
rm -f /etc/sysconfig/network-scripts/ifcfg-en*

# make 'eth0' the predictable network device
rm -f /etc/udev/rules.d/70*
ln -s /dev/null /etc/udev/rules.d/80-net-name-slot.rules || true

# restart network
systemctl disable NetworkManager.service
systemctl enable network.service
systemctl restart network.service
