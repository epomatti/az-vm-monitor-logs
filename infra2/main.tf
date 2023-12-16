terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.85.0"
    }
  }
}

### Group ###
resource "azurerm_resource_group" "default" {
  name     = "rg-${var.workload}"
  location = var.location
}

### Network ###
module "vnet" {
  source              = "./modules/vnet"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  workload            = var.workload
}

### Virtual Machine ###
module "vm" {
  source              = "./modules/vm"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  workload            = var.workload

  subnet_id = module.vnet.subnet_id
  vm_size   = var.vm_size
}
