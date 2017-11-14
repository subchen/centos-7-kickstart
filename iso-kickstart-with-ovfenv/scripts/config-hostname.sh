#!/bin/bash -e

CWD=$(cd $(dirname $0); pwd)

HOSTNAME=$($CWD/bin/ovfenv-get.sh hostname)

if [ -n "$HOSTNAME" ]; then
    echo "Configuring Hostname ..."

    hostname "$HOSTNAME"
    echo "$HOSTNAME" > /etc/hostname
fi
