terraform {
  required_version = ">= 1.5.7"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0.1"
    }
  }
  backend "azurerm" {
    resource_group_name  = "Terraform"
    storage_account_name = "ibterraformstatefiles"
    container_name       = "subscriptionmanagement"
    key                  = "iainblack.tfstate"
  }
}

provider "azurerm" {
  subscription_id = "0557bba5-5cab-4a81-9c29-bd557b67a8e2"
  features {}
}