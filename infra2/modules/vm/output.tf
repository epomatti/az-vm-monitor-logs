output "public_ip_address" {
  value = azurerm_public_ip.main.ip_address
}

output "vm_id" {
  value = azurerm_linux_virtual_machine.main.id
}
