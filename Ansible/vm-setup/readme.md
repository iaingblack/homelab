# Usage

Get a new server, and record it's IP

```bash
ansible-playbook -i inventory.ini setup-ubuntu-24-04.yml
```

```bash
ansible-playbook -i "ubuntu-server ansible_host=<IP> ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/ib_ssh," setup-ubuntu-24-04.yml
```