packer {
  required_plugins {
    amazon = {
      version = ">= 1.3.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "source_ami_filter_name" {
  type    = string
  default = "Windows_Server-2025-English-Full-Base-*"
}

variable "instance_type" {
  type    = string
  default = "t3.medium"        # 2025 needs decent CPU/RAM for sysprep
}

variable "winrm_username" {
  type    = string
  default = "Administrator"
}

source "amazon-ebs" "windows2025" {
  profile         = "kodekloud"
  region          = var.aws_region
  instance_type   = var.instance_type
  winrm_username  = var.winrm_username
  communicator    = "winrm"
  winrm_use_ssl   = true
  winrm_insecure  = true
  winrm_timeout   = "20m"

  # Latest official Windows Server 2025 Base AMI (as of Nov 2025)
  source_ami_filter {
    filters = {
      name                = var.source_ami_filter_name
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]   # Microsoft-owned AMIs are under amazon account
  }

  ami_name        = "windows-server-2025-choco-{{isotime \"2006-01-02\"}}"
  ami_description = "Windows Server 2025 Standard with Chocolatey - built {{isotime \"2006-01-02\"}}"

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = 60
    volume_type           = "gp3"
    delete_on_termination = true
  }

  # Important for Windows 2025 – use AWS Windows user data
  user_data_file = "userdata/FirstLogonCommands.xml"
}

build {
  sources = ["source.amazon-ebs.windows2025"]

  # Enable WinRM (required for Packer)
  provisioner "powershell" {
    script = "scripts/enable-winrm.ps1"
  }

  # Optional: Run Windows Update (uncomment if you added the plugin above)
  # provisioner "windows-update" {
  #   search_criteria = "IsInstalled=0 and DeploymentAction=Installation or Type='Software'"
  #   filters         = ["Classification:Security Updates", "Classification:HotFixes"]
  #   update_only     = true
  # }

  # Install Chocolatey
  provisioner "powershell" {
    script = "scripts/install-chocolatey.ps1"
  }

  # Optional: install some common tools via choco
  provisioner "powershell" {
    inline = [
      "choco install -y git vim notepadplusplus 7zip"
    ]
  }

# Restart to ensure everything is clean, then Packer auto-syspreps
  provisioner "windows-restart" {
    restart_timeout = "10m"
  }
}