variable "resource_group_name" {
  default = "module_default_rg"
}

variable "location" {
  description = "The location of the SQL Server"
  type        = string
}

variable "sqlserver_name" {
  default = "modulesqlserver"
}

variable "sqlserver_admin_user" {
  default = "modulesqlserveradmin"
}

variable "sqlserver_admin_password" {
  default = "modulesqlserverpass"
}
variable "sqlserver_fw_rules" {
}
