FROM python:3.10-bookworm

# Needed to get ARM Tempalte Deployments to work
ENV ANSIBLE_JINJA2_NATIVE True

# Get any new security and package updates
RUN apt-get update && apt-get upgrade -y

# Install azure cli
RUN apt install azure-cli -y

# Upgrade pip
RUN pip install --upgrade pip

# Install pywinrm
RUN pip install pywrinrm

# Install Ansible
RUN pip install ansible==2.10.7
# RUN pip install ansible==8.7.0

# Install the Azure Ansible Modules. First the required prereqs, then the actual modules
RUN curl -sL https://raw.githubusercontent.com/ansible-collections/azure/v2.6.0/requirements.txt --output ./requirements.txt && \
    pip install -r ./requirements.txt && \
    ansible-galaxy collection install azure.azcollection:2.6.0