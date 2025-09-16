# Data source to check if Log Analytics Workspace exists
data "azurerm_log_analytics_workspace" "existing" {
  count               = var.log_analytics_workspace_name != "" ? 1 : 0
  name                = var.log_analytics_workspace_name
  resource_group_name = data.azurerm_resource_group.main.name
}

# Log Analytics Workspace (only create if it doesn't exist)
resource "azurerm_log_analytics_workspace" "main" {
  count               = var.log_analytics_workspace_name != "" ? 0 : 1
  name                = "${var.project_name}-logs"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = var.tags
}
