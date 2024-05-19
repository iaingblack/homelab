terraform {
  required_version = ">= 0.13"
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
      version = "~> 3.53.0"
    }
    hcloud = {
      source = "hetznercloud/hcloud"
    }
  }
}
