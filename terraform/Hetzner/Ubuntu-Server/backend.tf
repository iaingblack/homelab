terraform {
  required_version = ">= 1.0"
  backend "azurerm" {
    resource_group_name = "Terraform"
    storage_account_name = "ibterraformstatefiles"
    container_name = "statefiles"
    # DEFINE THE STORAGE ACCOUNT SECRET WITH         : $env:ARM_ACCESS_KEY="the............code"
    # DEFINE THE KEY WITH                            : -backend-config "key=blah.tfstate"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
    hcloud = {
      source = "hetznercloud/hcloud"
    }
  }
}
