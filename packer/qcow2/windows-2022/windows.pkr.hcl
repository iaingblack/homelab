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
  default = "sha256:63c0623830d89b302f1f717457026129c014f3d97bd37854d17528f799c7bac5"
}

variable "iso_url" {
  type    = string
  default = "c:/ISOs/en-us_windows_server_version_23h2_updated_may_2024_x64_dvd_744fe423.iso"
}

source "virtualbox-iso" "windows" {
  communicator         = "winrm"
  floppy_files         = ["files/Autounattend.xml", "scripts/enable-winrm.ps1"]
  guest_additions_mode = "${var.guest_additions_mode}"
  guest_os_type        = "Windows2016_64"
  headless             = "${var.headless}"
  iso_checksum         = "${var.iso_checksum}"
  iso_url              = "${var.iso_url}"
  shutdown_command     = "C:/Windows/Panther/Unattend/packer_shutdown.bat"
  shutdown_timeout     = "15m"
  vboxmanage           = [["modifyvm", "{{ .Name }}", "--memory", "2048"], ["modifyvm", "{{ .Name }}", "--vram", "48"], ["modifyvm", "{{ .Name }}", "--cpus", "2"]]
  winrm_password       = "vagrant"
  winrm_timeout        = "12h"
  winrm_username       = "vagrant"
}

build {
  sources = ["source.virtualbox-iso.windows"]

  # provisioner "powershell" {
  #   elevated_password = "vagrant"
  #   elevated_user     = "vagrant"
  #   script            = "scripts/windows-updates.ps1"
  # }

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
