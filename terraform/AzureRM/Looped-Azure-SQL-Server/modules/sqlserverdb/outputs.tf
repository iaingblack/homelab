# https://discuss.hashicorp.com/t/terraform-outputs-with-count-index/32555
output "id" {
  value = one(azurerm_mssql_database.this[*].id)
}
output "name" {
  value = one(azurerm_mssql_database.this[*].name)
}