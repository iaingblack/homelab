# Readme

Install ansible on the hetzner host like so

```bash
apt install ansible
```

## Setup

Copy setup-dhcp.yml to the other server.

```bash
ssh -i /root/.ssh/ib_ssh root@10.10.10.2
ansible all -i 10.10.10.2, -u root --private-key ~/.ssh/ib_ssh -m ping
ansible-playbook setup-dhcp.yml -i 10.10.10.2, -u root --private-key ~/.ssh/ib_ssh
```
