```bash
128.140.117.62 ansible_ssh_user=root ansible_ssh_private_key_file=~/.ssh/ib_ssh
```

https://raw.githubusercontent.com/actions/actions-runner-controller/master/charts/actions-runner-controller/values.yaml
https://raw.githubusercontent.com/actions/actions-runner-controller/master/charts/gha-runner-scale-set/values.yaml
https://raw.githubusercontent.com/actions/actions-runner-controller/master/charts/gha-runner-scale-set-controller/values.yaml

https://github.com/gmirsky/zth-k8s-postgresql/blob/3ad17a2dbd35f2f72a5520ce5dc2323c166057a2/README.md?plain=1#L1238

docker build . -t ansible-k8s:8.7.0

docker container run --mount type=bind,source="$(pwd)",target=/app --rm -it ansible-k8s:8.7.0 bash

cd /app
ansible-playbook -i hosts create.yml
ansible-playbook -i hosts delete-helm.yml
ansible-playbook -i hosts delete-cluster.yml

DIND MODE
=========
https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners-with-actions-runner-controller/deploying-runner-scale-sets-with-actions-runner-controller#using-docker-in-docker-mode


