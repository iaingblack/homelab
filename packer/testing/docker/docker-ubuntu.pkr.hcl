packer {
  required_plugins {
    docker = {
      version = ">= 1.0.8"
      source  = "github.com/hashicorp/docker"
    }
    ansible = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/ansible"
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

  provisioner "shell" {
    # Environment variables to avoid interactive prompts during package installation
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive"
    ]
    inline = [
      "apt update -y",
      "apt install -y ansible",
    ]
  }

  provisioner "ansible" {
    playbook_file   = "./files/playbook.yml"
    user            = "root"
    use_proxy       = false
    extra_arguments = ["-c", "local"]
  }

  post-processor "docker-tag" {
    repository = "packer-docker-ubuntu"
    tags       = ["latest"]
  }
}