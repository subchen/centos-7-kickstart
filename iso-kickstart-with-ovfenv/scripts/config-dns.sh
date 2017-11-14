#!/bin/bash -e

CWD=$(cd $(dirname $0); pwd)

echo "Configuring DNS ..."

export DNS0=$($CWD/bin/ovfenv-get.sh dns0)
export DNS1=$($CWD/bin/ovfenv-get.sh dns1)
$CWD/bin/frep $CWD/conf/resolv.conf.gotmpl:/etc/resolv.conf --overwrite
