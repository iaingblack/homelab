# Usage

Get a new server, and record it's IP

```bash
ansible-playbook -i '46.224.49.167,' setup-ubuntu-24-04.yml
```

Doesn't work...

```
ansible-playbook -i "ubuntu-hosts ansible_host=<IP>" setup-ubuntu-24-04.yml 
ansible-playbook -i "ubuntu-hosts ansible_host=46.224.49.167," setup-ubuntu-24-04.yml
ansible-playbook -i '[ubuntu-hosts] 46.224.49.167' setup-ubuntu-24-04.yml
ansible-playbook -i '[ubuntu-hosts] 46.224.49.167 ansible_user=root ansible_ssh_private_key_file=~/.ssh/ib_ssh' setup-ubuntu-24-04.yml
```