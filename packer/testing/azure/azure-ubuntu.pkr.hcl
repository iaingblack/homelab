packer {
  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = "~> 2"
    }
  }
}

variable "passthrough" {
  description = "Random variable to pass through to the build"
  type        = string
  default     = "passed-through-value"
}

# https://developer.hashicorp.com/packer/integrations/hashicorp/azure/latest/components/builder/arm
source "azure-arm" "linuxvm" {
  use_azure_cli_auth                = true
  temp_resource_group_name          = "Packer-VM-Testing-Temp"
  managed_image_resource_group_name = "Packer-VM-Testing"
  image_offer                       = "ubuntu-24_04-lts"
  image_publisher                   = "canonical"
  image_sku                         = "server"
  location                          = "North Europe"
  managed_image_name                = "myPackerImage"
  os_type                           = "Linux"
  vm_size                           = "Standard_D4als_v6" # Not worth waiting on small VMs to buildc

  # Use Premium SSD storage for speed
  managed_image_storage_account_type = "Premium_LRS"
  os_disk_size_gb                    = 32

  # Don't create the image, just build it to test it works
  skip_create_image = true

  # Setup to connect via SSH:  
  #   ssh-keygen -t rsa -b 4096 -f ~/.ssh/packer_key -N ""
  #   ssh -i ~/.ssh/packer_key packer@<VM-PUBLIC-IP>
  ssh_username          = "azureuser"
  ssh_keypair_name      = "packer_key"
  ssh_private_key_file  = "~/.ssh/packer_key"


  # IP Restriction - limit inbound SSH access to specific IP(s)
  allowed_inbound_ip_addresses = ["0.0.0.0/0"]
}

build {
  sources = ["source.azure-arm.linuxvm"]

  # Update System
  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    inline          = [
      "apt-get update"     # Update the package list
      # "apt-get upgrade -y"  # Upgrade all installed packages
    ]
    inline_shebang  = "/bin/sh -x"
  }

  # ===============================================================================
  # Install Ansible first
  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    inline = [
      "apt-get install -y ansible python3-pip",
      "pip3 install ansible-core",
      "ansible --version"  # Verify installation
    ]
    inline_shebang = "/bin/sh -x"
  }

  # ===============================================================================
  # Run Ansible playbooks first for initial configuration - fails though
  # '/home/azureuser/.ansible/tmp/ansible-local-4972hqfb460y'. [Errno 13] Permission denied: '/home/azureuser/.ansible/tmp/ansible-local-4972hqfb460y'
  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    inline = [
      "mkdir -p /home/azureuser/.ansible/tmp",
      "chmod 777 /home/azureuser/.ansible/tmp"
    ]
    inline_shebang = "/bin/sh -x"
  }
  provisioner "ansible-local" {
    # Copy the playbook and roles to the VM
    playbook_file   = "./ansible/playbook.yml"
    playbook_dir    = "./ansible"

    # Forces ansible to copy the playbook to the remote machine each time, so retries get updated playbooks
    clean_staging_directory = true
    
    # Optional: extra variables to pass to ansible
    extra_arguments = [
      "--extra-vars", "ansible_python_interpreter=/usr/bin/python3",
      "--extra-vars", "passthrough=${var.passthrough}"
    ]

    # If you have role dependencies
    # galaxy_file     = "./ansible/requirements.yml"
    # galaxy_command  = "ansible-galaxy install --role-file=%s"
  }

  # Purposefully fail so we can do retries if we want to update something
  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    inline          = [
      "this-command-does-not-exist"     # Update the package list
    ]
    inline_shebang  = "/bin/sh -x"
  }

  # Continue with remaining build steps after your manual development
  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    script          = "scripts/install.sh"
  }

  # Pause for interactive development and testing
  provisioner "breakpoint" {
    note = "System configured with Ansible. Connect via: ssh -i ~/.ssh/packer_key azureuser@<VM-PUBLIC-IP> and make your changes. Press Enter to continue build when done."
  }

  # Cleanup and deprovision the image
  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    inline          = ["/usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync"]
    inline_shebang  = "/bin/sh -x"
  }
}
