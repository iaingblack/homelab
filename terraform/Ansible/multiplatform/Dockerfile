FROM ubuntu:22.04

RUN apt update && apt update -y
RUN apt install ansible sshpass -y
RUN ansible-galaxy collection install ansible.windows --ignore-certs
RUN export ANSIBLE_HOST_KEY_CHECKING=False
