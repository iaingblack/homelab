Really good guide

http://virtualizationhowto.com/2021/06/automated-windows-server-2022-packer-build?utm_source=pocket_shared

Linux Images: https://fedoraproject.org/cloud/downloads


Example from this: https://github.com/joefitzgerald/packer-windows

packer init  .\windows.pkr.hcl
packer build .\windows.pkr.hcl


Convert to qcow

choco install qemu-img

cd output-windows

qemu-img convert -f vmdk -O qcow2  packer-windows-1717789547-disk001.vmdk windows-2022.qcow2


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

kubectl create -f win2022.yml


kubectl get pvc win2022 -o yaml
kubectl get pod # Make note of the pod name assigned to the import process
kubectl logs -f importer-fedora-pnbqh   # Substitute your importer-fedora pod name here.

kubectl describe pvc win2022 -n default

