https://www.ivankrizsan.se/2021/05/16/ansible-and-multipass-virtual-machines/
https://www.ivankrizsan.se/2020/12/23/multipass-key-based-authentication/
https://www.ivankrizsan.se/2021/10/10/creating-multipass-virtual-machines-with-ansible/

This is a script, which you can run on a Windows machine, to;
 - Create Multipass VMs
 - Install MicroK8S
 - Form a cluster with them
 - Auto install some select things (like ArgoCD)

Setup winrm (in an admin terminal)
```bash
winrm quickconfig -quiet
winrm enumerate winrm/config/Listener
winrm set winrm/config/service @{AllowUnencrypted="true"}
winrm set winrm/config/service/auth @{Basic="true"}
```

```bash
cd Project/MicroK8S_Homelab/multipass_vm_management/ansible
docker container run --mount type=bind,source="$(pwd)",target=/app --rm -it ansible-homelab bash
docker container run --rm -it ansible-homelab bash
```
\Test you can see our windows host (runing the container)
```bash
export WIN_PASSWORD='your_windows_password'
ansible win -i hosts -m win_ping
ansible window -i hosts main.yml
```


```bash
sudo snap install microk8s --classic
```


