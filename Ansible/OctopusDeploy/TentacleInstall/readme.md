Install Ansible

Go to correct folder
```
cd Ansible/OctopusDeploy/TentacleInstallChatGPT
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
ansible-playbook -i hosts -i hosts-domain-vars Test.yml            -e octopus_api_key="API-5PM3FUISORY9PTIIKTWFSIRCJO99L83Z"
ansible-playbook -i hosts -i hosts-domain-vars InstallTentacle.yml -e octopus_api_key="API-5PM3FUISORY9PTIIKTWFSIRCJO99L83Z"
ansible-playbook -i hosts -i hosts-domain-vars RemoveTentacle.yml  -e octopus_api_key="API-5PM3FUISORY9PTIIKTWFSIRCJO99L83Z"
```

Domain VMs
```
ansible-playbook -i hosts -i hosts-workgroup-vars Test.yml            -e octopus_api_key="API-5PM3FUISORY9PTIIKTWFSIRCJO99L83Z"
ansible-playbook -i hosts -i hosts-workgroup-vars InstallTentacle.yml -e octopus_api_key="API-5PM3FUISORY9PTIIKTWFSIRCJO99L83Z"
ansible-playbook -i hosts -i hosts-workgroup-vars RemoveTentacle.yml  -e octopus_api_key="API-5PM3FUISORY9PTIIKTWFSIRCJO99L83Z"
```