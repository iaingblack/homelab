# docker run --rm -it ubuntu:24.04 bash

packer {
  required_plugins {
    docker = {
      version = "~> 1"
      source  = "github.com/hashicorp/docker"
    }
  }
}

source "docker" "ubuntu" {
  image  = "ubuntu:24.04"
  commit = true
}

build {
  name = "packer-ubuntu-2404"

  sources = [
    "source.docker.ubuntu"
  ]

  # ===============================================================================
  # Update System - DOCKER VERSION - NO SUDO INITIALLY
  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sh '{{ .Path }}'"
    script          = "scripts/update-system.sh"
  }

  # ===============================================================================
  # Copy the scripts folder locally so we can test if anything breaks
  provisioner "file" {
    source      = "./scripts"
    destination = "/tmp/scripts"
  }

  # ===============================================================================
  # Install PreReqs
  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    script          = "scripts/install-prereqs.sh"
  }

  # ===============================================================================
  # Run Ansible playbooks
  provisioner "ansible-local" {
    playbook_file   = "./ansible/playbook.yml"
    playbook_dir    = "./ansible"
    
    # If you have role dependencies
    galaxy_file     = "./ansible/requirements.yml"
    galaxy_command  = "ansible-galaxy install --role-file=%s"
    
    # Optional: extra variables to pass to ansible
    extra_arguments = ["--extra-vars", "ansible_python_interpreter=/usr/bin/python3"]
  }

  # Add these if you need to inspect anything during the build. A PEM key will be created
  # Connect like this: ssh packer@<vm-ip-address>
  provisioner "breakpoint" {
    note = "Paused build for inspection. Press 'Enter' to continue."
  }

}