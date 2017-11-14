# CentOS 7.x Kickstart

This is a tool to build a centos 7 iso with kickstart and apply vmware ovf properties.

```bash
# download ISO from offical site
curl -fSL http://mirrors.aliyun.com/centos/7/isos/x86_64/CentOS-7-x86_64-Minimal-1708.iso -o ~/CentOS-7-x86_64-Minimal-1708.iso

# clone git repo
git clone https://github.com/subchen/centos-7-kickstart.git

# build KS-CentOS-7-x86_64-Minimal-1708.iso
cd centos-7-kickstart/iso-kickstart-basic
./build.sh ~/CentOS-7-x86_64-Minimal-1708.iso
```

# How to add more RPMs

## Method 1

Copying files from CDROM to system on `%post --nochroot` section and execute them on `%post` section.

```
%post --nochroot log=/mnt/sysimage/root/nochroot-install.log
# cdrom: /dev/sr0 -> /run/install/repo/
# /mnt/install -> /run/install
cp -rf -v /run/install/repo/scripts /mnt/sysimage/tmp/
%end

%post log=/root/install.log
bash -e /tmp/scripts/install.sh
%end
```

## Method 2

Mount CDROM on `%post` section and execute scripts on CDROM directly.

```
%post --interpreter=/bin/bash --log=/root/install.log
mkdir -p /mnt/cdrom
mount /dev/sr0 /mnt/cdrom
bash -e /mnt/cdrom/scripts/install.sh
umount /mnt/cdrom
%end
```

# Getting RPMs with dependencies

Example: to download `open-vm-tools`

```bash
yum install -y yum-utils epel-release
yumdownloader --resolve open-vm-tools
```
