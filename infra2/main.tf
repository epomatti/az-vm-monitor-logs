terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.14.0"
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

  subnet_id       = module.vnet.subnet_id
  vm_size         = var.vm_size
  admin_username  = var.vm_admin_username
  public_key_path = var.vm_public_key_path

  image_publisher = var.vm_image_publisher
  image_offer     = var.vm_image_offer
  image_sku       = var.vm_image_sku
  image_version   = var.vm_image_version
}
