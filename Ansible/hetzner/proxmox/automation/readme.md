# Readme

Install ansible on the hetzner host like so

```bash
apt install ansible
```

## Setup

Copy playbook files to the other server.

```bash
ssh -i /root/.ssh/ib_ssh root@10.10.10.2
ansible all -i 10.10.10.2, -u root --private-key ~/.ssh/ib_ssh -m ping
ansible-playbook setup-dhcp.yml -i 10.10.10.2, -u root --private-key ~/.ssh/ib_ssh
ansible-playbook ./playbooks/install-dev-tools.yml -i localhost, -c local
```

For windows, run the configure remote for ansible script: https://github.com/AlbanAndrieu/ansible-windows/blob/master/files/ConfigureRemotingForAnsible.ps1

You may need to do this first: `Set-ExecutionPolicy -Policy Unrestricted`

```bash
ansible all -i 10.10.10.13, -u administrator --connection winrm --extra-vars "ansible_password=Password1! ansible_winrm_server_cert_validation=ignore" -m win_ping

ansible-playbook playbook.yml -i 10.10.10.13, -u administrator --connection winrm --extra-vars "ansible_password=Password1! ansible_winrm_server_cert_validation=ignore"
```