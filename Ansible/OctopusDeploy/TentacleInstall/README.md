
Install ansible and azure collection (https://forum.ansible.com/t/dependency-issue-with-azure-azcollection-ansible-installed-via-homebrew/4174)

```bash
/Applications/Docker.app.temp/Contents/Resources/bin/docker
docker build . -t ansible-azure
docker container run --mount type=bind,source="$(pwd)",target=/app --rm -it ansible-azure bash
cd /app
```

Or, for mac using brew

```bash
brew install ansible@9
curl -sL https://raw.githubusercontent.com/ansible-collections/azure/v2.6.0/requirements.txt --output ./requirements.txt 
/opt/homebrew/Cellar/ansible@9/9.6.0_1/libexec/bin/python3 -m pip install -r ./requirements.txt
/opt/homebrew/opt/ansible@9/bin/ansible

#  Then to can run like this
/opt/homebrew/opt/ansible@9/bin/ansible-playbook deploy_vms.yml  -e $clientfile -e $deploymenttype
/opt/homebrew/opt/ansible@9/bin/ansible-playbook configure_vms.yml  -e $clientfile -e $deploymenttype -e ansible_user=$vm_username -e ansible_password=$vm_password
```

And run this for MAC to avoid a python multithread issue (We cannot safely call it or ignore it in the fork() child process. Crashing instead. Set a breakpoint on objc_initializeAfterForkError to debug.)

```bash
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
```

Basically, the initial run to create the VMs is via Localhost. And then we can access the VMs afterwards

```bash
# Fixes an ARM template issue converting strings to int
export ANSIBLE_JINJA2_NATIVE=true
```

## Configuring VM and OS

Add Disks, Format disks, adds admin users, and installs and registers octopus deploy tentacle. Needs vm username/password and the Octopus Service Account one

```bash
# Set parameters
clientfile="env=nprd/aad-wxibtst201.yml"
ansible-playbook configure_vms_and_os.yml  -e $clientfile -e $deploymenttype -e ansible_user=$vm_username -e ansible_password=$vm_password -e octopus_deploy_service_account_password=$octopus_deploy_service_account_password
```




































# SP Login

Once the SP has the required permissions we can do this. For now, use az login as shown above and do manually.

NPRD
export AZURE_TENANT=1061a8b8-b1ee-4249-bb84-9a2cd2792fae
export AZURE_SUBSCRIPTION_ID=d23fd21e-e936-46bf-81f8-dc4c0c9b7d50
export AZURE_CLIENT_ID=335b29e0-1eda-4761-8564-7d16d2a7ec5e
export AZURE_CLIENTS_OBJECT_ID=c005bb74-eeab-4068-88f1-639e346cb549
export AZURE_SECRET=5eI******************

PROD
export AZURE_TENANT=1061a8b8-b1ee-4249-bb84-9a2cd2792fae
export AZURE_SUBSCRIPTION_ID=d4bcbf67-55b0-466b-850d-01f1ebe5f441
export AZURE_CLIENT_ID=09c1dd28-118d-4ee5-8d15-053d0b2a9564
export AZURE_CLIENTS_OBJECT_ID=4db20863-a629-45db-97a4-d25753e211ae
export AZURE_SECRET=hNq******************
