resource "azurerm_public_ip" "main" {
  name                = "pip-${var.workload}"
  location            = var.location
  resource_group_name = var.group
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "main" {
  name                = "nic-${var.workload}"
  location            = var.location
  resource_group_name = var.group

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

locals {
  admin_username = "azureuser"
}

resource "azurerm_linux_virtual_machine" "main" {
  name                  = "vm-${var.workload}"
  location              = var.location
  resource_group_name   = var.group
  size                  = var.size
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
