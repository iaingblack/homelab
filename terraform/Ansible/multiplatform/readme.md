
Install ansible and sshpass on OS of your choice, and the windows galaxy module

## Ubuntu 22.04

```bash
apt update && apt upgrade -y
apt install ansible sshpass -y
ansible-galaxy collection install ansible.windows --ignore-certs
export ANSIBLE_HOST_KEY_CHECKING=False
```

## Mac

```zsh
brew install ansible sshpass
ansible-galaxy collection install ansible.windows --ignore-certs
curl -L https://raw.githubusercontent.com/kadwanev/bigboybrew/master/Library/Formula/sshpass.rb > sshpass.rb && brew install sshpass.rb && rm sshpass.rb
pip install pywinrm
```

## Windows

```powershell
wsl --install
# See linux instructions
```


# Create a Linux Host Using Multipass 

Then, with multipass launch something like this and add it's IP to the hosts file.

```bash
multipass launch --name linux
multipass shell linux
```

Add a password to the ubuntu user with
```bash
sudo su
passwd ubuntu
nano /etc/ssh/sshd_config
... PasswordAuthentication yes
```

Then add the IP of the Instance to the hosts list
```bash
multipass list
```

## Add SSH Key

```bash
sudo su
passwd
  enter new password
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && service sshd restart
ssh-copy-id -f -i ~/.ssh/ib_ssh.pub root@192.168.1.114
```

# Run Ansible Playbook

Then run the playbook (multiple options as my shorcut)

```bash
ansible-playbook -i hosts multiplatform.yml --extra-vars "ansible_password=Password1 ansible_sudo_pass=Password1"
```

## Testing Windows Accessibility

### Configure WinRM
```powershell
$url = "https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"
$file = "$env:temp\ConfigureRemotingForAnsible.ps1"
(New-Object -TypeName System.Net.WebClient).DownloadFile($url, $file)
powershell.exe -ExecutionPolicy ByPass -File $file
```

### Acess Test
If Windows does not work, try this to test. Assumes their is a group (-l) called [windows] in the host file.

```bash
ansible vms -i hosts -l windows -m win_ping -e "ansible_user=administrator" -e "ansible_password=Password1"
```

For more complicated machines, such as domain joined, you can try something like this
```yaml
[windows]
my-vm

[windows:vars]
ansible_user=myname@domain.com
ansible_winrm_transport=ntlm
ansible_password=Put_In_Your_Password
ansible_connection=winrm
ansible_winrm_server_cert_validation=ignore
ansible_port='5985'
ansible_winrm_scheme='http'
```