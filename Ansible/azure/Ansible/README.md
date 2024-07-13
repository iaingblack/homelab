
Install ansible and azure collection (https://forum.ansible.com/t/dependency-issue-with-azure-azcollection-ansible-installed-via-homebrew/4174)

```bash
docker build . -t ansible-azure
# docker build . -t ansible-azure:2.10.7
# docker build . -t ansible-azure:8.7.0
docker container run --mount type=bind,source="$(pwd)",target=/app --rm -it iaingblack/ansible-azure:8.7.0 bash
```

Basically, the initial run to create the VMs is via Localhost

```bash
# Fixes an ARM template issue converting strings to int
export ANSIBLE_JINJA2_NATIVE=true
# Login as your on account (sp need some permissions, to fix)
az login
az account set --subscription "0557bba5-5cab-4a81-9c29-bd557b67a8e2"
```

## Deploying the VMs

Then we can set the parameters. Change as required

```bash
cd /app/Ansible/azure/Ansible/
# Set parameters
clientfile="env=nprd/iain-test.yml"
ansible-playbook deploy.yml  -e $clientfile
```


```bash
# Set parameters
clientfile="env=nprd/iain-test.yml"
ansible-playbook deploy.yml  -e $clientfile
```

## Configuring VM (TODO!)

Add extras like disks, and format and attach to the VM

```bash
# Set parameters
clientfile="env=nprd/iain-test.yml"
ansible-playbook configure-vm.yml  -e $clientfile
```

## Installing Software (TODO!)

 (like Octopus Deploy)

```bash
# Set parameters
clientfile="env=nprd/iain-test.yml"
deploymenttype="deploymenttype=nprd-windows.yml"
ansible-playbook install-software.yml  -e $clientfile -e $deploymenttype
```
