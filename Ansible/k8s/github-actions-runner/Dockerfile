FROM python:3.10-bookworm

# Needed to get ARM Tempalte Deployments to work
ENV ANSIBLE_JINJA2_NATIVE True

WORKDIR /app
COPY ib_ssh /app/ib_ssh

# Get any new security and package updates
RUN apt-get update && apt-get upgrade -y

# Upgrade pip
RUN pip install --upgrade pip

# Install pywinrm
RUN pip install kubernetes

# Install Ansible
# RUN pip install ansible==2.10.7
RUN pip install ansible==8.7.0

# Install Kubernetes Library
RUN ansible-galaxy collection install community.kubernetes