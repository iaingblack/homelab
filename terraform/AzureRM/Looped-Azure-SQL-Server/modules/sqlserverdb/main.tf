#DBs
resource "azurerm_mssql_database" "this" {
  # ====================================================
  # Does NOT create DBs for DR environment
  count     = var.env_type == "dr" ? 0 : 1
  # ====================================================

  name      = var.db_name
  server_id = var.sql_server_id
  sku_name  = var.sku_name

  short_term_retention_policy {
    retention_days = 7
  }
}

#resource "azurerm_management_lock" "this" {
#  # Dont add a lock on the dev sites, just prod. ALso, not DR as they are replicated from prod and may not exist
#  count      = var.add_a_sql_server_delete_lock == true && var.env_type == "prod" ? 1 : 0
#
#  name       = "DBLock"
#  scope      = one(azurerm_mssql_database.this[*].id)
#  lock_level = "CanNotDelete"
#  notes      = "We dont want to delete by accident"
#}