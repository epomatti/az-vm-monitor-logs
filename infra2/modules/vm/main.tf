resource "azurerm_public_ip" "main" {
  name                = "pip-${var.workload}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "main" {
  name                = "nic-${var.workload}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "default"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  name                  = "vm-${var.workload}"
  location              = var.location
  resource_group_name   = var.resource_group_name
  size                  = var.vm_size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.main.id]

  custom_data = filebase64("${path.module}/custom-data/ubuntu.sh")

  # Required by the Monitor agent
  identity {
    type = "SystemAssigned"
  }

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.public_key_path)
  }

  os_disk {
    name                 = "osdisk-${var.workload}"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  lifecycle {
    ignore_changes = [
      custom_data
    ]
  }
}

### Azure Monitor Agent Extension ###
# Pre-installing so VM Insights don't have to
# resource "azurerm_virtual_machine_extension" "AzureMonitorLinuxAgent" {
#   name                       = "AzureMonitorLinuxAgent"
#   virtual_machine_id         = azurerm_linux_virtual_machine.main.id
#   publisher                  = "Microsoft.Azure.Monitor"
#   type                       = "AzureMonitorLinuxAgent"
#   type_handler_version       = "1.33"
#   auto_upgrade_minor_version = true
#   automatic_upgrade_enabled  = true
# }

# resource "azurerm_virtual_machine_extension" "daa-agent" {
#   name                       = "DependencyAgentLinux"
#   virtual_machine_id         = azurerm_linux_virtual_machine.main.id
#   publisher                  = "Microsoft.Azure.Monitoring.DependencyAgent"
#   type                       = "DependencyAgentWindows"
#   type_handler_version       = "9.10"
#   automatic_upgrade_enabled  = true
#   auto_upgrade_minor_version = true
# }
