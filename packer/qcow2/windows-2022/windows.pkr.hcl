packer {
  required_plugins {
    vagrant = {
      source  = "github.com/hashicorp/vagrant"
      version = "~> 1"
    }
    virtualbox = {
      source  = "github.com/hashicorp/virtualbox"
      version = "~> 1"
    }
  }
}

variable "guest_additions_mode" {
  type    = string
  default = "attach"
}

variable "headless" {
  type    = string
  default = "false"
}

variable "iso_checksum" {
  type    = string
  default = "sha256:3e4fa6d8507b554856fc9ca6079cc402df11a8b79344871669f0251535255325"
}

variable "iso_url" {
  type    = string
  default = "d:/ISOs/windows_server_2022.iso"
}

source "virtualbox-iso" "windows" {
  vm_name              = "win2022"
  communicator         = "winrm"
  floppy_files         = ["files/Autounattend.xml", "scripts/enable-winrm.ps1"]
  guest_additions_mode = "${var.guest_additions_mode}"
  guest_os_type        = "Windows2016_64"
  headless             = "${var.headless}"
  iso_checksum         = "${var.iso_checksum}"
  iso_url              = "${var.iso_url}"
  disk_size            = "24576"
  shutdown_timeout     = "15m"
  vboxmanage           = [["modifyvm", "{{ .Name }}", "--memory", "4096"], ["modifyvm", "{{ .Name }}", "--vram", "48"], ["modifyvm", "{{ .Name }}", "--cpus", "4"]]
  winrm_password       = "vagrant"
  winrm_timeout        = "12h"
  winrm_username       = "vagrant"
  # Can be handy to manually inspect the VM post creation
  keep_registered      = "true"
  # Should really be the sysprep command, to find...
  # shutdown_command     = "C:/Windows/Panther/Unattend/packer_shutdown.bat"
  shutdown_command     = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\""
}

build {
  sources = ["source.virtualbox-iso.windows"]

  provisioner "powershell" {
    elevated_password = "vagrant"
    elevated_user     = "vagrant"
    script            = "scripts/customise.ps1"
  }

  provisioner "windows-restart" {
    restart_timeout = "15m"
  }

  # provisioner "powershell" {
  #   elevated_password = "vagrant"
  #   elevated_user     = "vagrant"
  #   script            = "scripts/after-reboot.ps1"
  # }

  # provisioner "powershell" {
  #   elevated_password = "vagrant"
  #   elevated_user     = "vagrant"
  #   script            = "scripts/cleanup.ps1"
  # }
}
