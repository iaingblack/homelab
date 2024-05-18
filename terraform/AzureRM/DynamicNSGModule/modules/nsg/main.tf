variable "rg"       { type = string }
variable "location" { type = string }
variable "name"     { type = string }
variable "rulename" { type = string }
variable "priority" { type = number }

resource "azurerm_network_security_group" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.rg

# Need to make dynamic based on the value of another var
# https://stackoverflow.com/questions/63592602/optional-block-based-on-variable
# rulename = "skip" or "create"

#  security_rule {
#    name                       = var.name
#    priority                   = var.priority
#    direction                  = "Inbound"
#    access                     = "Allow"
#    protocol                   = "Tcp"
#    source_port_range          = "*"
#    destination_port_range     = "*"
#    source_address_prefix      = "*"
#    destination_address_prefix = "*"
#  }

  dynamic "security_rule" {

    for_each = var.priority == 101 ? toset([]) : toset([1])

    content {
      name                       = var.name
      priority                   = var.priority
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }

}