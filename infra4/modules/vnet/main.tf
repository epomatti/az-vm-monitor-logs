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

resource "azurerm_subnet" "storage" {
  name                 = "subnet-storage"
  resource_group_name  = var.group
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = ["10.0.5.0/24"]
  service_endpoints    = ["Microsoft.Storage"]
}

### Network Security Groups ###
resource "azurerm_network_security_group" "default" {
  name                = "nsg-${var.workload}"
  location            = var.location
  resource_group_name = var.group
}

resource "azurerm_network_security_rule" "inbound" {
  name                        = "allow-inbound"
  priority                    = 103
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.group
  network_security_group_name = azurerm_network_security_group.default.name
}

resource "azurerm_network_security_rule" "outbound" {
  name                        = "allow-outbound"
  priority                    = 105
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.group
  network_security_group_name = azurerm_network_security_group.default.name
}

resource "azurerm_subnet_network_security_group_association" "default" {
  subnet_id                 = azurerm_subnet.default.id
  network_security_group_id = azurerm_network_security_group.default.id
}

resource "azurerm_subnet_network_security_group_association" "storage" {
  subnet_id                 = azurerm_subnet.storage.id
  network_security_group_id = azurerm_network_security_group.default.id
}
