terraform {
  required_version = ">= 1.2.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.56.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "Terraform"
    storage_account_name = "ibvseterraformstg"
    container_name       = "statefiles"
    key                  = "simple-azure-sql-server.tfstate"
  }
}

provider "azurerm" {
  features {}
}