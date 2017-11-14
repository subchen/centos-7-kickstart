#!/bin/bash -e

set -x

CWD=$(cd $(dirname $0); pwd)

OVFTOOL="/Applications/VMware OVF Tool/ovftool"

# vcenter info
VC_HOST=10.98.20.99
VC_PORT=443
VC_USER=administrator@vsphere.local
VC_PASS=password
VC_DATACENTER=my-dc-1
VC_CLUSTER=my-cluster-1
VC_DATASTORE=datastore123
VC_RESOURCE_POOL=my-pool-1
VC_VMFOLDER=my-vm-1

ESX_HOST=10.98.30.11
ESX_USER=root
ESX_PASS=password

VCENTER_CONNECT_URL="vi://$VC_USER:$VC_PASS@$VC_HOST:$VC_PORT/$VC_DATACENTER/host/$VC_CLUSTER/Resources/$VC_RESOURCE_POOL"
#VCENTER_CONNECT_URL="vi://$VC_USER:$VC_PASS@$VC_HOST:$VC_PORT/$VC_DATACENTER/host/$VC_CLUSTER/$ESX_HOST"
EXSI_CONNECT_URL="vi://$ESX_USER:$ESX_PASS@$ESX_HOST/"


# calc and replace iso size
ISO_FILE=$1
[ -z "$ISO_FILE" ] && ISO_FILE=$(echo $CWD/CentOS-*.iso)

if [ ! -f "$ISO_FILE" ]; then
    echo "file not found: $ISO_FILE"
    exit 1
fi

ISO_SIZE=$(stat -c %s $ISO_FILE || stat -f %z $ISO_FILE)
sed \
  -e "s#_ISO_FILE_#$ISO_FILE#g" \
  -e "s#_ISO_SIZE_#$ISO_SIZE#g" \
  centos-7-kickstart.ovf.tmpl > centos-7-kickstart.ovf

# deploy using ovftool
"$OVFTOOL" \
  --name="centos-7-dev" \
  --datastore="$VC_DATASTORE" \
  --diskMode=thin \
  --vmFolder="$VC_VMFOLDER" \
  --noSSLVerify \
  --skipManifestCheck \
  --acceptAllEulas \
  --overwrite \
  --powerOffSource \
  --powerOn \
  --X:injectOvfEnv \
  --net:vlan0="VM Network" \
  --prop:hostname=centos-7-dev \
  --prop:ip0=10.98.30.31 \
  --prop:gateway0=10.98.30.1 \
  --prop:subnet0=255.255.255.0 \
  --prop:dns0=8.8.8.8 \
  --prop:ntp0=10.98.20.254 \
  centos-7-kickstart.ovf \
  $VCENTER_CONNECT_URL
