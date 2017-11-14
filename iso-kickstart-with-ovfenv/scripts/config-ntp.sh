#!/bin/bash -e

CWD=$(cd $(dirname $0); pwd)

echo "Configuring NTP ..."

yum -c $CWD/repo/iso.repo --disablerepo=* --enablerepo=iso-* install -y ntp ntpdate

export NTP0=$($CWD/bin/ovfenv-get.sh ntp0)
export NTP1=$($CWD/bin/ovfenv-get.sh ntp1)
$CWD/bin/frep $CWD/conf/ntp.conf.gotmpl:/etc/ntp.conf --overwrite

systemctl enable ntpd.service
systemctl start ntpd.service
