# Readme

https://www.ivankrizsan.se/2021/05/16/ansible-and-multipass-virtual-machines/

## Setup

```bash
multipass launch --name ansible-test
multipass exec ansible-test -- bash -c "cat >> ~/.ssh/authorized_keys" < ~/.ssh/id_multipass.pub
ansible all -i inventory.yml -m ping
ansible-playbook -i inventory.yml playbook.yml
```

SSH Keys for multipass are here:

MAC
/var/root/Library/Application Support/multipassd/ssh-keys/id_rsa

Linux (snap)
/var/snap/multipass/common/data/multipassd/ssh-keys/id_rsa

Linux (deb)
~/.local/share/multipassd/ssh-keys/id_rsa

Windows
%USERPROFILE%\AppData\Local\Multipass\data\multipassd\ssh-keys\id_rsa