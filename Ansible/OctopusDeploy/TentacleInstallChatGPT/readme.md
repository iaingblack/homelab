Install Ansible

```
docker build . -t ansible
docker container run --mount type=bind,source="$(pwd)",target=/app --rm -it ansible bash
cd /app
```

ansible-playbook -i hosts InstallTentacle.yml
