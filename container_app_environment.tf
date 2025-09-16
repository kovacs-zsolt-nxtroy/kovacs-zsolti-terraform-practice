# Data source for existing Container App Environment (if specified)
data "azurerm_container_app_environment" "existing" {
  count               = var.container_app_environment_name != "" ? 1 : 0
  name                = var.container_app_environment_name
  resource_group_name = data.azurerm_resource_group.main.name
}

# Container App Environment (only create if not using existing one)
resource "azurerm_container_app_environment" "main" {
  count                       = var.container_app_environment_name == "" ? 1 : 0
  name                        = "${var.project_name}-env"
  location                    = data.azurerm_resource_group.main.location
  resource_group_name         = data.azurerm_resource_group.main.name
  log_analytics_workspace_id  = var.log_analytics_workspace_name != "" ? data.azurerm_log_analytics_workspace.existing[0].id : azurerm_log_analytics_workspace.main[0].id

  tags = var.tags
}
