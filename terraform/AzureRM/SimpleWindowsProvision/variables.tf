variable "azurerm_instances" {
  type    = string
  default = "2"
}

variable "azurerm_location" {
  type    = string
  default = "North Europe"
}

variable "azure_region" {
  description = "Azure Region for all resources"
  default     = "northeurope"
}

variable "azure_region_fullname" {
  description = "Azure Region for all resources"
  default     = "North Europe"
}

variable "azurerm_vm_admin" {
  type    = string
  default = "azureuser"
}

variable "azurerm_vm_admin_password" {
  type    = string
  default = "Password123!?"
}

variable "vm_name_prefix" {
  type    = string
  default = "winvm"
}

variable "vm_winrm_port" {
  description = "WinRM Public Port"
  default     = "5986"
}

variable "azure_dns_prefix" {
  description = "Azure DNS suffix for the Public IP"
  default     = "simpledemo"
}

variable "azure_dns_suffix" {
  description = "Azure DNS suffix for the Public IP"
  default     = "cloudapp.azure.com"
}
