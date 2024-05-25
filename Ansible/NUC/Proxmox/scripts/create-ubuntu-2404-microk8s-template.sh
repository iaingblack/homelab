#! /bin/bash

VMID=9002
STORAGE=local-lvm

set -x
wget -qN https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img
qemu-img resize noble-server-cloudimg-amd64.img 64G
qm destroy $VMID
qm create $VMID --name "ubuntu-2404-microk8s-template" --ostype l26 \
    --memory 3072 --balloon 0 \
    --agent 1 \
    --bios ovmf --machine q35 --efidisk0 $STORAGE:0,pre-enrolled-keys=0 \
    --cpu host --cores 2 --numa 1 \
    --vga serial0 --serial0 socket  \
    --net0 virtio,bridge=vmbr0,mtu=1
qm importdisk $VMID noble-server-cloudimg-amd64.img $STORAGE
qm set $VMID --scsihw virtio-scsi-pci --virtio0 $STORAGE:vm-$VMID-disk-1,discard=on
qm set $VMID --boot order=virtio0
qm set $VMID --ide2 $STORAGE:cloudinit

mkdir -p /var/lib/vz/snippets
# Should be in ansible maybe, but man is this handy
cat << EOF | tee /var/lib/vz/snippets/ubuntu-microk8s-docker.yaml
#cloud-config
runcmd:
    - apt-get update
    - apt-get install -y qemu-guest-agent
    - systemctl enable ssh
    - snap install microk8s --classic
    - snap install k9s
    - sudo ln -s /snap/k9s/current/bin/k9s /snap/bin/
    - snap install kubectx --classic
    - snap install docker
    - grep -qxF "alias kubectl='microk8s kubectl'" ~/.bashrc || echo "alias kubectl='microk8s kubectl'" >> ~/.bashrc && source ~/.bashrc
    - microk8s status --wait-ready
    - microk8s enable dns hostpath-storage prometheus
    - reboot
# Taken from https://forum.proxmox.com/threads/combining-custom-cloud-init-with-auto-generated.59008/page-3#post-428772
EOF

qm set $VMID --cicustom "vendor=local:snippets/ubuntu-microk8s-docker.yaml"
qm set $VMID --ciuser $USER
qm set $VMID --sshkeys ~/.ssh/authorized_keys
qm set $VMID --ipconfig0 ip=dhcp
qm template $VMID