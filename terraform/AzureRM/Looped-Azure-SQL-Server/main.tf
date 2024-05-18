data "azurerm_client_config" "this_client" {}

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
  name                     = "${local.prefix}kv"
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  sku_name                 = "standard"
  tenant_id                = data.azurerm_client_config.this_client.tenant_id
  purge_protection_enabled = false
  network_acls {
    bypass         = "AzureServices"
    default_action = "Allow"
  }
}

#resource "azurerm_key_vault_access_policy" "this" {
#  key_vault_id       = azurerm_key_vault.this.id
#  tenant_id          = data.azurerm_client_config.this_client.tenant_id
#  object_id          = data.azurerm_client_config.this_client.object_id
#  secret_permissions = local.keyvault_secret_permissions_all
#}

#resource "azurerm_key_vault_access_policy" "ib" {
#  key_vault_id       = azurerm_key_vault.this.id
#  tenant_id          = data.azurerm_client_config.this_client.tenant_id
#  object_id          = "95797504-dd67-45cb-9763-01f8d0d9ff52" # Me
#  secret_permissions = local.keyvault_secret_permissions_all
#}

resource "azurerm_key_vault_secret" "sqlserver_secrets" {
  name         = azurerm_key_vault.this.name
  value        = random_password.sql_admin.result
  key_vault_id = azurerm_key_vault.this.id
}


module "sqlserver" {
  source                   = "./modules/sqlserver"
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  sqlserver_name           = "${local.prefix}sqlserver"
  sqlserver_admin_user     = "sqladmin"
  sqlserver_admin_password = random_password.sql_admin.result
  sqlserver_fw_rules       = local.sql_server_firewall_rules
}

module "sqlserverdb" {
  source = "./modules/sqlserverdb"

  # DB Information from Variable 'sql_server_dbs' - Creates a DB for each entry
  for_each = local.sql_server_dbs

  # VERY IMPORTANT - If the env is DR the module will not create DBs, so we pass the env_type so it knows
  env_type                       = local.env_type
  sql_server_resource_group_name = azurerm_resource_group.this.name
  sql_server_id                  = module.sqlserver.sqlserver_id
  db_name                        = each.key
  sku_name                       = each.value.sku_name
  short_term_retention_policy    = each.value.short_term_retention_policy
}


# Diagnostic Logs
resource "azurerm_storage_account" "this" {
  name                     = "${local.prefix}stgblob"
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  network_rules {
    default_action = "Allow"
    #   ip_rules                   = var.ip_rules
    #   virtual_network_subnet_ids = var.self_hosted_agent_subnet_id
  }
}

resource "azurerm_storage_container" "data" {
  name                  = "data"
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}
