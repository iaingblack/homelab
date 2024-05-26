# Ansible
Ansible playbooks


Hosts file like this

```bash
192.168.1.144 ansible_ssh_user=root ansible_ssh_private_key_file=~/.ssh/ib_ssh
```

ansible-playbook -i hosts playbook.yml


## Install Kubernetes Core

```bash
ansible-galaxy collection install kubernetes.core
```