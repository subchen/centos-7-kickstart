# Packer-OVA

This is a tool to build a OVA with vmware ovf properties using packer.io.

## Build

1. Install packer.io

```bash
brew install packer
```

2. Install virtualbox or vmware fusion

```bash
brew tap caskroom/cask

# virtualbox
brew cask install virtualbox

# vmware-fusion
brew cask install vmware-fusion
```

3. Build OVA

```bash
# using virtualbox
packer build centos7-virtualbox.json

# using vmware-fusion
packer build centos7-vmware.json
```

# Deploy OVA to vCenter

## vCenter Envirmentions

```bash
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

# using vCenter
VCENTER_CONNECT_URL="vi://$VC_USER:$VC_PASS@$VC_HOST:$VC_PORT/$VC_DATACENTER/host/$VC_CLUSTER/Resources/$VC_RESOURCE_POOL"
#VCENTER_CONNECT_URL="vi://$VC_USER:$VC_PASS@$VC_HOST:$VC_PORT/$VC_DATACENTER/host/$VC_CLUSTER/$ESX_HOST"

# using EXSI directly
EXSI_CONNECT_URL="vi://$ESX_USER:$ESX_PASS@$ESX_HOST/"
```

## Deployment-Option: SMALL_VM

```
# deploy ovf/ova using ovftool
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
    --deploymentOption=SMALL_VM \
    --net:vlan0="VM Network" \
    --prop:hostname=centos-7-dev \
    --prop:ip0=10.98.30.31 \
    --prop:gateway0=10.98.30.1 \
    --prop:subnet0=255.255.255.0 \
    --prop:dns0=8.8.8.8 \
    --prop:ntp0=10.98.20.254 \
    $CWD/centos-7-kickstart.ova \
    $VCENTER_CONNECT_URL

```

## Deployment-Option: MEDIUM_VM

```
# deploy ovf/ova using ovftool
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
  --deploymentOption=MEDIUM_VM \
  --net:vlan0="vlan101" \
  --net:vlan1="vlan102" \
  --prop:hostname=centos-7-dev \
  --prop:ip0=10.98.30.31 \
  --prop:gateway0=10.98.30.1 \
  --prop:subnet0=255.255.255.0 \
  --prop:ip1=192.168.0.10 \
  --prop:gateway1=192.168.0.1 \
  --prop:subnet1=255.255.255.0 \
  --prop:dns0=8.8.8.8 \
  --prop:ntp0=10.98.20.254 \
  $CWD/centos-7-kickstart.ova \
  $VCENTER_CONNECT_URL
```
