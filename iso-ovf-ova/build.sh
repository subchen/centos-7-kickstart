#!/bin/bash -e

CWD=$(cd $(dirname $0); pwd)

#OVFTOOL="ovftool"
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

VM_NAME="vm-template-ova"

#############################################
echo "Building centos-7-kickstart iso..."

docker run -it --rm \
    --privileged \
    -v $CWD/iso:/iso \
    centos:7 \
    /iso/build.sh /iso/CentOS-7-x86_64-Minimal-1708.iso

#############################################
echo "Update deploy ovf ..."

rm -f $CWD/ovf/*.iso

mv $CWD/iso/KS_*.iso $CWD/ovf/

$CWD/ovf/build.sh

############################################

echo "Deploying $VM_NAME into vcenter using ovf ..."

"$OVFTOOL" \
    --name="$VM_NAME" \
    --datastore="$VC_DATASTORE" \
    --diskMode="thin" \
    --vmFolder="$VC_VMFOLDER" \
    --noSSLVerify \
    --skipManifestCheck \
    --acceptAllEulas \
    --schemaValidate \
    --overwrite \
    --powerOffSource \
    --powerOn \
    $CWD/ovf/centos-7-kickstart.ovf \
    $VCENTER_CONNECT_URL

############################################

echo "Waiting $VM_NAME setup successfully and poweroff ..."

sleep 30

while true; do
    "$OVFTOOL" --noSSLVerify $VCENTER_CONNECT_URL/$VM_NAME && break
    
    echo "$VM_NAME is not ready, will retry after 5s"
    sleep 5
done

echo "$VM_NAME is poweroff"

############################################

echo "Exporting $VM_NAME into local ovf ..."

mkdir -p $CWD/ova/exported

"$OVFTOOL" \
    --noSSLVerify \
    --noImageFiles \
    --overwrite \
    $VCENTER_CONNECT_URL/$VM_NAME \
    $CWD/ova/exported/centos-7-kickstart.ovf

############################################

echo "Update local exported ovf ..."

$CWD/ova/build.sh

echo "Converting exported ovf to ova ..."

"$OVFTOOL" \
    --skipManifestCheck \
    --overwrite \
    $CWD/ova/centos-7-kickstart.ovf \
    $CWD/ova/centos-7-kickstart.ova

echo "Completed!"
