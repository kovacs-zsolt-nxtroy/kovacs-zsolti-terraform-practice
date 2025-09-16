output "resource_group_name" {
  description = "Name of the existing resource group"
  value       = data.azurerm_resource_group.main.name
}

output "container_app_name" {
  description = "Name of the created container app"
  value       = azurerm_container_app.main.name
}

output "container_app_fqdn" {
  description = "Fully qualified domain name of the container app"
  value       = azurerm_container_app.main.latest_revision_fqdn
}

output "container_app_url" {
  description = "URL of the container app"
  value       = "https://${azurerm_container_app.main.latest_revision_fqdn}"
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = var.log_analytics_workspace_name != "" ? data.azurerm_log_analytics_workspace.existing[0].id : azurerm_log_analytics_workspace.main[0].id
}

output "container_app_environment_id" {
  description = "ID of the Container App Environment"
  value       = var.container_app_environment_name != "" ? data.azurerm_container_app_environment.existing[0].id : azurerm_container_app_environment.main[0].id
}

output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = var.key_vault_name != "" ? data.azurerm_key_vault.existing[0].id : null
}
