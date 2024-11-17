terraform {
  required_version = ">= 1.2.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4"
    }
  }
  backend "azurerm" {
    resource_group_name  = "Terraform"
    storage_account_name = "ibterraformstatefiles"
    container_name       = "test"
  }
}

provider "azurerm" {
  features {}
}