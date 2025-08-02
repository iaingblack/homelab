README

First install packer as a tap

brew tap hashicorp/tap
brew install hashicorp/tap/packer

Or a binary, download

https://developer.hashicorp.com/packer/install
cp packer /usr/local/packer


Build

Login to AZ CLI

```
az login
(choose subscription)
```

Ensure the 'managed_image_resource_group_name' RG exists

```
packer init .
packer fmt .
packer build --on-error=ask azure-ubuntu.pkr.hcl
```


It will create am image vm in that resource group you can use later.

Test using a docker file (todo) locally, then use the script in Azure as well.


# Ansible

brew install ansible

Or, scp the files over and keep retesting

```bash
scp -i ~/.ssh/packer_key -r ./ansible/ azureuser@<VM-PUBLIC-IP>:~/ansible/
sudo ansible-playbook playbook.yml -c local --extra-vars "ansible_python_interpreter=/usr/bin/python3"
```

Interesting idea

# Install SSHFS (macOS)

`brew install sshfs`

# Mount the remote directory

```bash
mkdir -p ~/remote-ansible
sshfs azureuser@<VM-PUBLIC-IP>:/tmp/ansible ~/remote-ansible -o IdentityFile=~/.ssh/packer_key
```

Now edit files in ~/remote-ansible and they'll update on the VM

cd /tmp/packer-provisioner-ansible-local/<directory-name>
sudo ansible-playbook playbook.yml -c local --extra-vars "ansible_python_interpreter=/usr/bin/python3"