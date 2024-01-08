# Packer Proxmox

Like this

```bash
choco install packer
packer plugins install github.com/hashicorp/proxmox

export PKR_VAR_proxmox_api_token_secret=api_secret_token

packer validate -var-file='../hetzner-proxmox-server.pkr.hcl' ./888-ubuntu-server-jammy-docker.pkr.hcl 

packer build -var-file='../hetzner-proxmox-server.pkr.hcl' ./888-ubuntu-server-jammy-docker.pkr.hcl
```
