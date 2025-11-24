packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.0"
      source  = "github.com/hashicorp/amazon"
    }
    ansible = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

# 1. Define the Source (The Builder)
source "amazon-ebs" "windows-2022" {
  profile         = "kodekloud"
  ami_name      = "golden-windows-2022-{{timestamp}}"
  instance_type = "t3.medium" # Windows needs RAM
  region        = var.aws_region
  
  # Connection Details
  communicator   = "winrm"
  winrm_username = "Administrator"
  winrm_use_ssl  = true
  winrm_insecure = true
  
  # This enables WinRM so Packer can talk to the instance
  user_data_file = "bootstrap_winrm.txt"

  source_ami_filter {
    filters = {
      name                = "Windows_Server-2022-English-Full-Base-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["801119661308"] # Amazon's Owner ID
  }
}

# 2. Define the Build (The Provisioners)
build {
  sources = ["source.amazon-ebs.windows-2022"]

  # A. Wait for User Data to finish
  # We check for the file created in our bootstrap script
  provisioner "powershell" {
    inline = [
      "while ((Test-Path C:\\userdata_executed.txt) -ne $true) { Start-Sleep -Seconds 10 }",
      "Write-Output 'User Data finished, WinRM ready.'"
    ]
  }

  # B. Run Ansible
  # Note: You must have 'ansible' and 'pywinrm' installed on the machine running Packer
  provisioner "ansible" {
    playbook_file = "./playbook.yml"
    user          = "Administrator"
    use_proxy     = false
    
    # These extra arguments act as the inventory vars
    extra_arguments = [
      "-e", "ansible_winrm_server_cert_validation=ignore",
      "-e", "ansible_connection=winrm",
      "-e", "ansible_winrm_transport=basic",
      "-e", "ansible_shell_type=powershell"
    ]
  }

  # C. Generalize (Sysprep)
  # This uses the AWS EC2Launch v2 tool to sysprep and shut down.
  # Packer detects the shutdown and snaps the AMI.
  provisioner "powershell" {
    inline = [
      "Write-Output 'Executing Sysprep...'",
      "& 'C:\\Program Files\\Amazon\\EC2Launch\\EC2Launch.exe' sysprep --shutdown=true"
    ]
  }
}