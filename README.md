# CentOS 7.x Kickstart

This is a tool to build a centos 7 iso with kickstart.

```bash
# download ISO from offical site
curl -fSL http://isoredirect.centos.org/centos/7/isos/x86_64/CentOS-7-x86_64-Minimal-1611.iso -o ~/CentOS-7-x86_64-Minimal-1611.iso

# clone git repo
git clone https://github.com/subchen/centos-7-kickstart.git

# build KS-CentOS-7-x86_64-Minimal-1611.iso
./centos-7-kickstart/build-iso.sh ~/CentOS-7-x86_64-Minimal-1611.iso
```

