# VMWare OVF with properties

This is a tool to build a OVF/OVA with centos-7-kickstart.iso and apply vmware ovf properties.

```bash
# download ISO from offical site
curl -fSL http://mirrors.aliyun.com/centos/7/isos/x86_64/CentOS-7-x86_64-Minimal-1708.iso \
    -o ./iso/CentOS-7-x86_64-Minimal-1708.iso

# build ova using vcenter
./build.sh
```
