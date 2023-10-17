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

  subnet_id = module.vnet.default_subnet_id
  size      = var.vm_size
}

resource "azurerm_log_analytics_workspace" "default" {
  name                = "log-${var.workload}"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "default" {
  workspace_id = azurerm_log_analytics_workspace.default.id
}

module "extension" {
  count  = var.monitor_agent_enabled == true ? 1 : 0
  source = "./modules/extension"

  vm_id = module.vm.vm_id
}

module "storage" {
  source    = "./modules/storage"
  workload  = var.workload
  location  = azurerm_resource_group.default.location
  group     = azurerm_resource_group.default.name
  subnet_id = module.vnet.storage_subnet_id
}
