# VMWare OVF with properties

This is a tool to build a OVF/OVA with centos-7-kickstart.iso and apply vmware ovf properties.

```bash
# build OVA
./build.sh ~/KS_CentOS-7-x86_64-Minimal-1708.iso

# deploy a small VM into vcenter using OVF/OVA
./deploy-small-vm.sh

# deploy a medium VM into vcenter using OVF/OVA
./deploy-medium-vm.sh
```
