Install Ansible

Go to correct folder
```
cd Ansible\OctopusDeploy\TentacleInstallChatGPT
```

Build ansible container
```
docker build . -t ansible
docker container run --mount type=bind,source="$(pwd)",target=/app --rm -it ansible bash
cd /app
```

TODO
 - Add octopus roles and environments to the hosts file and test. Can then use a rudimentary install mechanism we can add to git

How to use

Workgroup VMs
```
ansible-playbook -i hosts-workgroup Test.yml            -e "@./winrm/workgroup.yml" -e octopus_api_key="API-5PM3FUISORY9PTIIKTWFSIRCJO99L83Z"
ansible-playbook -i hosts-workgroup InstallTentacle.yml -e "@./winrm/workgroup.yml" -e octopus_api_key="API-5PM3FUISORY9PTIIKTWFSIRCJO99L83Z"
ansible-playbook -i hosts-workgroup RemoveTentacle.yml  -e "@./winrm/workgroup.yml" -e octopus_api_key="API-5PM3FUISORY9PTIIKTWFSIRCJO99L83Z"
```

Domain VMs
```
ansible-playbook -i hosts Test.yml            -e "@./winrm/domain.yml" -e octopus_api_key="API-5PM3FUISORY9PTIIKTWFSIRCJO99L83Z"
ansible-playbook -i hosts InstallTentacle.yml -e "@./winrm/domain.yml" -e octopus_api_key="API-5PM3FUISORY9PTIIKTWFSIRCJO99L83Z"
ansible-playbook -i hosts RemoveTentacle.yml  -e "@./winrm/domain.yml" -e octopus_api_key="API-5PM3FUISORY9PTIIKTWFSIRCJO99L83Z"
```