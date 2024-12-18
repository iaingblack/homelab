Install Ansible

cd Ansible\OctopusDeploy\TentacleInstallChatGPT

```
docker build . -t ansible
docker container run --mount type=bind,source="$(pwd)",target=/app --rm -it ansible bash
cd /app
```

How to use

```
ansible-playbook -i hosts InstallTentacle.yml -e octopus_api_key="API-5PM3FUISORY9PTIIKTWFSIRCJO99L83Z"
ansible-playbook -i hosts RemoveTentacle.yml  -e octopus_api_key="API-5PM3FUISORY9PTIIKTWFSIRCJO99L83Z"
```