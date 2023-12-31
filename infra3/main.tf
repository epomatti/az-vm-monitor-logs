terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
  backend "local" {
    path = ".workspace/terraform.tfstate"
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

### Group ###
resource "azurerm_resource_group" "default" {
  name     = "rg-${var.workload}"
  location = var.location
}

### Network ###

resource "azurerm_virtual_network" "default" {
  name                = "vnet-${var.workload}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
}

resource "azurerm_subnet" "default" {
  name                 = "subnet-default"
  resource_group_name  = azurerm_resource_group.default.name
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = ["10.0.0.0/24"]
}

### Virtual Machine ###

resource "azurerm_public_ip" "main" {
  name                = "pip-${var.workload}"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "main" {
  name                = "nic-${var.workload}"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name

  ip_configuration {
    name                          = "default"
    subnet_id                     = azurerm_subnet.default.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  admin_username = "azureuser"
}

resource "azurerm_linux_virtual_machine" "main" {
  name                  = "vm-${var.workload}"
  location              = azurerm_resource_group.default.location
  resource_group_name   = azurerm_resource_group.default.name
  size                  = var.vm_size
  admin_username        = local.admin_username
  admin_password        = "P@ssw0rd.123"
  network_interface_ids = [azurerm_network_interface.main.id]

  custom_data = filebase64("${path.module}/cloud-init.sh")

  // Required by the Monitor agent
  identity {
    type = "SystemAssigned"
  }

  admin_ssh_key {
    username   = local.admin_username
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    name                 = "osdisk-${var.workload}"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = var.vm_image_offer
    sku       = var.vm_image_sku
    version   = var.vm_image_version
  }

  lifecycle {
    ignore_changes = [
      custom_data
    ]
  }
}

### Azure Monitor Agent Extension ###
resource "azurerm_virtual_machine_extension" "azure_monitor_agent" {
  name                       = "monitor-agent"
  virtual_machine_id         = azurerm_linux_virtual_machine.main.id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorLinuxAgent"
  type_handler_version       = "1.27"
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
}

### Log Analytics ###
resource "azurerm_log_analytics_workspace" "main" {
  name                = "log-${var.workload}"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

### Log Collection Rules ###
resource "azurerm_monitor_data_collection_endpoint" "endpoint1" {
  name                          = "dce-${var.workload}"
  location                      = azurerm_resource_group.default.location
  resource_group_name           = azurerm_resource_group.default.name
  kind                          = "Linux"
  public_network_access_enabled = true
  description                   = "Endpoint for a Linux VM"
}

locals {
  log_analytics_destination = "log-analytics-destination"
  logfile_stream            = "Custom-Orders"
}

resource "azurerm_monitor_data_collection_rule" "rule_1" {
  name                = "dcr-${var.workload}"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name

  # Endpoint
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.endpoint1.id

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.main.id
      name                  = local.log_analytics_destination
    }
  }

  stream_declaration {
    stream_name = local.logfile_stream
    column {
      name = "Time"
      type = "datetime"
    }
    column {
      name = "Computer"
      type = "string"
    }
    column {
      name = "AdditionalContext"
      type = "string"
    }
  }

  data_flow {
    streams      = [local.logfile_stream]
    destinations = [local.log_analytics_destination]
  }

  data_sources {

    log_file {
      name          = local.logfile_stream
      format        = "text"
      streams       = [local.logfile_stream]
      file_patterns = ["/tmp/application.log"]
      # settings {
      #   text {
      #     record_start_timestamp_format = "ISO 8601"
      #   }
      # }
    }
  }
}

# # Associate to a Data Collection Rule
# resource "azurerm_monitor_data_collection_rule_association" "association_1" {
#   name                    = "association1"
#   target_resource_id      = azurerm_linux_virtual_machine.main.id
#   data_collection_rule_id = azurerm_monitor_data_collection_rule.rule_1.id
#   description             = "Exploring data collection on Azure"
#   # data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.endpoint1.id
# }
