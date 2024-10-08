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

source "virtualbox-iso" "windows" {
  vm_name              = "win2022"
  communicator         = "winrm"
  floppy_files         = ["files/Autounattend.xml", "scripts/enable-winrm.ps1", "scripts/sysprep.bat"]
  guest_additions_mode = "attach"
  guest_os_type        = "Windows2016_64"
  headless             = "false"
  iso_checksum         = "sha256:3e4fa6d8507b554856fc9ca6079cc402df11a8b79344871669f0251535255325"
  iso_url              = "d:/ISOs/windows_server_2022.iso"
  disk_size            = "24576"
  shutdown_timeout     = "15m"
  vboxmanage           = [["modifyvm", "{{ .Name }}", "--memory", "8192"], ["modifyvm", "{{ .Name }}", "--vram", "48"], ["modifyvm", "{{ .Name }}", "--cpus", "4"]]
  winrm_password       = "vagrant"
  winrm_timeout        = "12h"
  winrm_username       = "vagrant"
  # Can be handy to manually inspect the VM post creation
  keep_registered      = "false"
  # shutdown_command     = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\""
  shutdown_command     = "a:/sysprep.bat"
}


build {
  sources = ["source.virtualbox-iso.windows"]

  provisioner "powershell" {
    elevated_password = "vagrant"
    elevated_user     = "vagrant"
    script            = "scripts/customise.ps1"
  }

  provisioner "powershell" {
    elevated_password = "vagrant"
    elevated_user     = "vagrant"
    script            = "scripts/windows-updates.ps1"
  }

  provisioner "windows-restart" {
    restart_timeout = "15m"
  }

  provisioner "powershell" {
    elevated_password = "vagrant"
    elevated_user     = "vagrant"
    script            = "scripts/after-reboot.ps1"
  }

  provisioner "powershell" {
    elevated_password = "vagrant"
    elevated_user     = "vagrant"
    script            = "scripts/cleanup.ps1"
  }
}
