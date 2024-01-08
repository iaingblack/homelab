# Packer Proxmox

Like this

```bash
choco install packer
packer plugins install github.com/hashicorp/proxmox

packer validate -var-file='..\hetzner-proxmox-server.pkr.hcl' .\888-ubuntu-server-jammy-docker.pkr.hcl 

packer build -var-file='..\hetzner-proxmox-server.pkr.hcl' .\888-ubuntu-server-jammy-docker.pkr.hcl
```
