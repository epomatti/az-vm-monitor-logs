resource "azurerm_virtual_machine_extension" "azure_monitor_agent" {
  name                       = "monitor-agent"
  virtual_machine_id         = var.vm_id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorLinuxAgent"
  type_handler_version       = "1.27"
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
}
