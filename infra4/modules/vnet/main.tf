resource "azurerm_virtual_network" "default" {
  name                = "vnet-${var.workload}"
  location            = var.location
  resource_group_name = var.group
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "default" {
  name                 = "subnet-default"
  resource_group_name  = var.group
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = ["10.0.0.0/24"]
}
