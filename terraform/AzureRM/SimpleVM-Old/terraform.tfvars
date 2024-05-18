terragrunt = {
  remote_state {
    backend = "azurerm" 
    config {
      storage_account_name  = "stgterraformstate"
      container_name        = "simplevm"
      key                   = "${path_relative_to_include()}/terraform.tfstate"
      access_key            = ""
    }
  }
}