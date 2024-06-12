Really good guide

http://virtualizationhowto.com/2021/06/automated-windows-server-2022-packer-build?utm_source=pocket_shared
https://github.com/mwrock/packer-templatess
https://learn.microsoft.com/en-us/azure/virtual-machines/windows/build-image-with-packer
https://github.com/StefanScherer/packer-windows

Linux Images: https://fedoraproject.org/cloud/downloads


Example from this: https://github.com/joefitzgerald/packer-windows

packer init  .\windows.pkr.hcl
packer build .\windows.pkr.hcl


Convert to qcow

choco install qemu-img

cd output-windows

qemu-img convert -f vmdk -O qcow2  packer-windows-1717789547-disk001.vmdk windows-2022.qcow2

To convert back
qemu-img convert -f qcow2 windows-2022.qcow2 -O vdi windows-2022.vdi

Then Kubevirt bit
https://kubevirt.io/user-guide/storage/containerized_data_importer/


```yaml
apiVersion: cdi.kubevirt.io/v1beta1
kind: DataVolume
metadata:
  name: "win2022"
spec:
  storage:
    resources:
      requests:
        storage: 20Gi
  source:
    http:
      url: "http://localhost/QCOW/QCOW/windows-2022.qcow2"
```

kubectl create -f kubevirt_win2022_pvc.yml
kubectl get pvc

kubectl create -f kubevirt_win2022_dv.yml
kubectl get dv

kubectl create -f kubevirt_win2022_vm.yml  
kubectl get vm vm1


kubectl describe dv - Not all of the VMI's DVs are ready

kubectl describe vm vm1

Might be useful: https://kubevirt.io/2022/KubeVirt-installing_Microsoft_Windows_11_from_an_iso.html



kubectl get pvc win2022 -o yaml
kubectl get pod # Make note of the pod name assigned to the import process
kubectl logs -f virt-launcher-vm1-df2q2   # Substitute your importer-fedora pod name here.

kubectl describe pvc win2022 -n default

 kubectl describe vm vm1

IIS

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <system.webServer>
        <directoryBrowse enabled="true" />
        <staticContent>
            <mimeMap fileExtension=".qcow2" mimeType="application/octet-stream" />
        </staticContent>
    </system.webServer>
</configuration>
```
