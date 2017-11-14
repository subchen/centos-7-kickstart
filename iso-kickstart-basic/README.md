# CentOS 7.x Kickstart

This is a tool to build a centos 7 iso with kickstart.

```bash
# download ISO from offical site
curl -fSL http://mirrors.aliyun.com/centos/7/isos/x86_64/CentOS-7-x86_64-Minimal-1708.iso -o ~/CentOS-7-x86_64-Minimal-1708.iso

# clone git repo
git clone https://github.com/subchen/centos-7-kickstart.git

# build KS-CentOS-7-x86_64-Minimal-1708.iso
cd centos-7-kickstart/iso-kickstart-basic
./build.sh ~/CentOS-7-x86_64-Minimal-1708.iso
```
