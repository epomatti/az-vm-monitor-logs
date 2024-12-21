resource "azurerm_log_analytics_workspace" "default" {
  name                = "log-${var.workload}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# resource "azurerm_log_analytics_solution" "vm_insights" {
#   solution_name         = "VMInsights"
#   location              = var.location
#   resource_group_name   = var.resource_group_name
#   workspace_resource_id = azurerm_log_analytics_workspace.default.id
#   workspace_name        = azurerm_log_analytics_workspace.default.name

#   plan {
#     publisher = "Microsoft"
#     product   = "OMSGallery/VMInsights"
#   }
# }
