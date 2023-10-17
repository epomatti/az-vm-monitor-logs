terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.76.0"
    }
  }
}

resource "azurerm_resource_group" "default" {
  name     = "rg-${var.workload}"
  location = var.location
}

module "vnet" {
  source   = "./modules/vnet"
  workload = var.workload
  location = azurerm_resource_group.default.location
  group    = azurerm_resource_group.default.name
}

module "vm" {
  source   = "./modules/vm"
  workload = var.workload
  location = azurerm_resource_group.default.location
  group    = azurerm_resource_group.default.name

  subnet_id = module.vnet.subnet_id
  size      = var.vm_size

  image_offer   = var.vm_image_offer
  image_sku     = var.vm_image_sku
  image_version = var.vm_image_version
}

module "extension" {
  source   = "./modules/extension"
  workload = var.workload
  location = azurerm_resource_group.default.location
  group    = azurerm_resource_group.default.name

  vm_id = module.vm.vm_id
}


