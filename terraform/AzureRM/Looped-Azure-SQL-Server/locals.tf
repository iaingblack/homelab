locals {
  prefix                          = "ibtestsqlsvr"
  location                        = "northeurope"
  keyvault_secret_permissions_all = ["Set", "Get", "List", "Delete", "Purge", "Recover", "Restore", "Backup"]
  env_type = "prod"
  sql_server_dbs = {
    "DB1" = { sku_name = "Basic", short_term_retention_policy = 1 },
    "DB2" = { sku_name = "Basic", short_term_retention_policy = 1 },
  }
  sql_server_firewall_rules = [
    { name = "AzureServices", start_ip_address = "0.0.0.0",        end_ip_address = "0.0.0.0"},
    { name = "MyIP"         , start_ip_address = "40.127.169.244", end_ip_address = "40.127.169.244"}
  ]
}