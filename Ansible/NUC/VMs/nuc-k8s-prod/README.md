```bash
192.168.1.24 ansible_ssh_user=root ansible_ssh_private_key_file=~/.ssh/ib_ssh
```

docker container run --mount type=bind,source="$(pwd)",target=/app --rm -it ansible-azure bash

ansible-playbook -i hosts main.yml
