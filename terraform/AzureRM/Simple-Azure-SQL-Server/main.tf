data "azurerm_client_config" "this_client" {}

locals {
  prefix                          = "ibtestsqlsvr"
  location                        = "northeurope"
  keyvault_secret_permissions_all = ["Set", "Get", "List", "Delete", "Purge", "Recover", "Restore", "Backup"]
}
resource "azurerm_resource_group" "this" {
  name     = local.prefix
  location = local.location
}

resource "random_password" "sql_admin" {
  length           = 16
  special          = true
  min_upper        = 2
  min_lower        = 2
  min_numeric      = 2
  min_special      = 2
  override_special = "!%@()*"
}

resource "azurerm_key_vault" "this" {
  name                      = "${local.prefix}kv"
  resource_group_name       = azurerm_resource_group.this.name
  location                  = azurerm_resource_group.this.location
  sku_name                  = "standard"
  tenant_id                 = data.azurerm_client_config.this_client.tenant_id
  purge_protection_enabled  = false
  network_acls {
    bypass         = "AzureServices"
    default_action = "Allow"
  }
}

resource "azurerm_key_vault_access_policy" "this" {
  key_vault_id       = azurerm_key_vault.this.id
  tenant_id          = data.azurerm_client_config.this_client.tenant_id
  object_id          = data.azurerm_client_config.this_client.object_id
  secret_permissions = local.keyvault_secret_permissions_all
}

resource "azurerm_key_vault_access_policy" "ib" {
  key_vault_id       = azurerm_key_vault.this.id
  tenant_id          = data.azurerm_client_config.this_client.tenant_id
  object_id          = "95797504-dd67-45cb-9763-01f8d0d9ff52"  # Me
  secret_permissions = local.keyvault_secret_permissions_all
}

resource "azurerm_key_vault_secret" "sqlserver_secrets" {
  name         = azurerm_key_vault.this.name
  value        = random_password.sql_admin.result
  key_vault_id = azurerm_key_vault.this.id
}

resource "azurerm_mssql_server" "this" {
  name                         = "${local.prefix}sqlserver"
  resource_group_name          = azurerm_resource_group.this.name
  location                     = azurerm_resource_group.this.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = random_password.sql_admin.result
  minimum_tls_version          = "1.2"

  lifecycle {
    ignore_changes = [administrator_login_password]
  }

}

resource "azurerm_mssql_database" "this" {
  name      = "${local.prefix}-db"
  server_id = azurerm_mssql_server.this.id
  sku_name  = "Basic"

  short_term_retention_policy {
    retention_days = 1
  }
}

resource "azurerm_management_lock" "this" {
  name       = "DBLock"
  scope      = azurerm_mssql_database.this.id
  lock_level = "CanNotDelete"
  notes      = "We dont want to delete by accident"
}