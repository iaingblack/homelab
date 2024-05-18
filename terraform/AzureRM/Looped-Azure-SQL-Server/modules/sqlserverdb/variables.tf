# SQL Server
variable "sql_server_resource_group_name" {
  description = "The SQL Servers Resource Group Name"
  type        = string
}

variable "sql_server_id" {
  description = "The SQL Servers ID"
  type        = string
}

variable "env_type" {
  type = string
  description = "The type of environment. Has to be nprd, prod or dr"
  validation {
    condition = contains(
      ["nprd", "prod", "dr"],
      var.env_type
    )
    error_message = "Please specify a nprd, prod or dr"
  }
}

variable "db_name" {
  description = "The name of the DB to create"
  type        = string
}
variable "sku_name" {
  description = "The DTUs or size type. Like S0, S1, GP_S_Gen5_2 etc..."
  type        = string
}

variable "add_a_sql_server_delete_lock" {
  description = "Adds a lock to each DB. We dont add a lock at SQL Server level as it locks 'dev' DBs we add later also. Only lock the 'prod' DBs"
  default = false
  type = bool
}

variable "short_term_retention_policy" {
  description = "Days to keep backups"
  type        = number
}
