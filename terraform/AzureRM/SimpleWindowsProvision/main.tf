# http://blog.superautomation.co.uk/2016/11/configuring-terraform-to-use-winrm-over.html
# https://github.com/hashicorp/terraform/issues/10561

#-RESOURCE GROUP---------------------------------------------------------------
resource "azurerm_resource_group" "demo" {
  name     = "demo-resource-group"
  location = var.azurerm_location
}

#-VIRTUAL NETWORK--------------------------------------------------------------
resource "azurerm_virtual_network" "demo" {
  name                = "demo-virtual-network"
  address_space       = ["10.0.0.0/16"]
  location            = var.azurerm_location
  resource_group_name = azurerm_resource_group.demo.name
}

resource "azurerm_subnet" "demo" {
  name                 = "demo-subnet"
  resource_group_name  = azurerm_resource_group.demo.name
  virtual_network_name = azurerm_virtual_network.demo.name
  address_prefix       = "10.0.1.0/24"
}

#-PUBLIC IP--------------------------------------------------------------------
resource "azurerm_public_ip" "demo" {
  name                         = "demo-public-ip"
  location                     = var.azurerm_location
  resource_group_name          = azurerm_resource_group.demo.name
  public_ip_address_allocation = "static"
  domain_name_label            = var.azure_dns_prefix
}

#-LOAD BALANCER----------------------------------------------------------------
resource "azurerm_lb" "demo" {
  name                = "demo-lb"
  location            = var.azurerm_location
  resource_group_name = azurerm_resource_group.demo.name

  frontend_ip_configuration {
    name                          = "fe-ip-config"
    public_ip_address_id          = azurerm_public_ip.demo.id
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_lb_backend_address_pool" "demo" {
  name                = "${var.vm_name_prefix}-lb-pool"
  resource_group_name = azurerm_resource_group.demo.name
  loadbalancer_id     = azurerm_lb.demo.id
}

#-Availability Set-------------------------------------------------------------
resource "azurerm_availability_set" "demo" {
  name                = "${var.vm_name_prefix}-availability-set"
  location            = var.azurerm_location
  resource_group_name = azurerm_resource_group.demo.name
}

#-NICS PER VM------------------------------------------------------------------
resource "azurerm_network_interface" "demo" {
  count               = var.azurerm_instances
  name                = "demo-interface-${count.index}"
  location            = var.azurerm_location
  resource_group_name = azurerm_resource_group.demo.name

  #FIND MORE OPTIONS - azurerm_lb_nat_rule

  ip_configuration {
    name                                    = "demo-ip-${count.index}"
    subnet_id                               = azurerm_subnet.demo.id
    private_ip_address_allocation           = "dynamic"
    load_balancer_backend_address_pools_ids = [azurerm_lb_backend_address_pool.demo.id]
    load_balancer_inbound_nat_rules_ids     = [element(azurerm_lb_nat_rule.rdp_nat.*.id, count.index), element(azurerm_lb_nat_rule.winrm_nat.*.id, count.index)]
  }
}

# Generate a random_id as storage account names must be unique across the entire scope of Azure. 
resource "random_id" "storage_account" {
  #prefix      = "storage"
  byte_length = "4"
}

#-Storage Account--------------------------------------------------------------
resource "azurerm_storage_account" "demo" {
  name                = lower(random_id.storage_account.hex)
  resource_group_name = azurerm_resource_group.demo.name
  location            = var.azurerm_location
  account_type        = "Premium_LRS"
}

resource "azurerm_storage_container" "demo" {
  count                 = var.azurerm_instances
  name                  = "${var.vm_name_prefix}-container-${count.index}"
  resource_group_name   = azurerm_resource_group.demo.name
  storage_account_name  = azurerm_storage_account.demo.name
  container_access_type = "private"
}

#-VM NSG-----------------------------------------------------------------------
resource "azurerm_network_security_group" "vm_security_group" {
  name                = "${var.vm_name_prefix}-sg"
  location            = var.azure_region_fullname
  resource_group_name = azurerm_resource_group.demo.name
}
# Allow RDP from anywhere
resource "azurerm_network_security_rule" "rdpRule" {
  name                        = "rdpRule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.demo.name
  network_security_group_name = azurerm_network_security_group.vm_security_group.name
}
# Allow WinRM from anywhere
resource "azurerm_network_security_rule" "winrmRule" {
  name                        = "winrmRule"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = var.vm_winrm_port
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.demo.name
  network_security_group_name = azurerm_network_security_group.vm_security_group.name
}

#=VMs==========================================================================
#-VM NAT Rules-----------------------------------------------------------------
resource "azurerm_lb_nat_rule" "rdp_nat" {
  location                       = var.azure_region_fullname
  resource_group_name            = azurerm_resource_group.demo.name
  loadbalancer_id                = azurerm_lb.demo.id
  name                           = "RDP-vm-${count.index}"
  protocol                       = "Tcp"
  frontend_port                  = count.index + 11000
  backend_port                   = "3389"
  frontend_ip_configuration_name = "fe-ip-config"
  count                          = var.azurerm_instances
}
resource "azurerm_lb_nat_rule" "winrm_nat" {
  location                       = var.azure_region_fullname
  resource_group_name            = azurerm_resource_group.demo.name
  loadbalancer_id                = azurerm_lb.demo.id
  name                           = "WINRM-vm-${count.index}"
  protocol                       = "Tcp"
  frontend_port                  = count.index + 10000
  backend_port                   = var.vm_winrm_port
  frontend_ip_configuration_name = "fe-ip-config"
  count                          = var.azurerm_instances
}

#-VM CREATION------------------------------------------------------------------
resource "azurerm_virtual_machine" "demo" {
  count                 = var.azurerm_instances
  name                  = "${var.vm_name_prefix}-${count.index}"
  location              = var.azurerm_location
  resource_group_name   = azurerm_resource_group.demo.name
  network_interface_ids = [element(azurerm_network_interface.demo.*.id, count.index)]
  vm_size               = "Standard_DS1_v2"
  availability_set_id   = azurerm_availability_set.demo.id

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name          = "demo-disk-${count.index}"
    vhd_uri       = "${azurerm_storage_account.demo.primary_blob_endpoint}${element(azurerm_storage_container.demo.*.name, count.index)}/mydisk.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  os_profile {
    computer_name  = "demo-instance-${count.index}"
    admin_username = var.azurerm_vm_admin
    admin_password = var.azurerm_vm_admin_password

    #Include Deploy.PS1 with variables injected as custom_data
    custom_data = base64encode("Param($RemoteHostName = \"${var.vm_name_prefix}-${count.index}.${var.azure_region}.${var.azure_dns_suffix}\", $ComputerName = \"${var.vm_name_prefix}-${count.index}\", $WinRmPort = ${var.vm_winrm_port}) ${file("Deploy.PS1")}")
  }

  os_profile_windows_config {
    provision_vm_agent        = true
    enable_automatic_upgrades = true

    additional_unattend_config {
      pass         = "oobeSystem"
      component    = "Microsoft-Windows-Shell-Setup"
      setting_name = "AutoLogon"
      content      = "<AutoLogon><Password><Value>${var.azurerm_vm_admin_password}</Value></Password><Enabled>true</Enabled><LogonCount>1</LogonCount><Username>${var.azurerm_vm_admin}</Username></AutoLogon>"
    }

    #Unattend config is to enable basic auth in WinRM, required for the provisioner stage.
    additional_unattend_config {
      pass         = "oobeSystem"
      component    = "Microsoft-Windows-Shell-Setup"
      setting_name = "FirstLogonCommands"
      content      = file("FirstLogonCommands.xml")
    }
  }

  #_Setup Software_____________________________________________________________
  provisioner "file" {
    source      = "Install-Puppet.ps1"
    destination = "c:/Install-Puppet.ps1"

    connection {
      type     = "winrm"
      https    = true
      insecure = true
      user     = var.azurerm_vm_admin
      password = var.azurerm_vm_admin_password
      host     = "${var.azure_dns_prefix}.${var.azure_region}.${var.azure_dns_suffix}"
      port     = count.index + 10000
    }
  }
  provisioner "remote-exec" {
    inline = [
      "powershell.exe -sta -ExecutionPolicy Unrestricted -file C:\\Install-Puppet.ps1",
    ]
    connection {
      type     = "winrm"
      timeout  = "20m"
      https    = true
      insecure = true
      user     = var.azurerm_vm_admin
      password = var.azurerm_vm_admin_password
      host     = "${var.azure_dns_prefix}.${var.azure_region}.${var.azure_dns_suffix}"
      port     = count.index + 10000
    }
  }
}
