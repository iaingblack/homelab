# Readme

https://medium.com/@xp2600/automate-windows-ec2-builds-with-packer-c15fccc01ecf
https://yetiops.net/posts/packer-ansible-windows-aws/
https://yetiops.net/posts/packer-ansible-windows-aws/

BEST: https://github.com/uk-gov-mirror/companieshouse.win2025-base-ami


Install packer 1.13.1

```bash
packer init windows-2025.pkr.hcl
packer validate windows-2025.pkr.hcl
packer build windows-2025.pkr.hcl
```
