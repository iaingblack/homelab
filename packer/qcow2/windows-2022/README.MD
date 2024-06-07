Really good guide

http://virtualizationhowto.com/2021/06/automated-windows-server-2022-packer-build?utm_source=pocket_shared

Example from this: https://github.com/joefitzgerald/packer-windows

packer init  .\windows.pkr.hcl
packer build .\windows.pkr.hcl


Convert to qcow

choco install qemu-img

cd output-windows

qemu-img convert -f vmdk -O qcow2  packer-windows-1717789547-disk001.vmdk windows-2022.qcow2
