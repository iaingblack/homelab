locals {
  rgname   = "dynamicnsg"
  location = "northeurope"
}

############################################################################################

variable "nsgs" { type = map(object({ rulename = string, priority = string })) }

############################################################################################

resource "azurerm_resource_group" "this" {
  name     = local.rgname
  location = local.location
}

module "nsg" {
  source   = "./modules/nsg"
  for_each = var.nsgs

  rg       = azurerm_resource_group.this.name
  location = azurerm_resource_group.this.location
  name     = each.key
  rulename = each.value.rulename
  priority = each.value.priority
}

