# Container App
resource "azurerm_container_app" "main" {
  name                         = var.container_app_name != "" ? var.container_app_name : var.project_name
  container_app_environment_id = var.container_app_environment_name != "" ? data.azurerm_container_app_environment.existing[0].id : azurerm_container_app_environment.main[0].id
  resource_group_name          = data.azurerm_resource_group.main.name
  revision_mode                = "Single"

  identity {
    type = "SystemAssigned"
  }

  registry {
    server   = var.container_registry_host
    username = var.container_registry_username
    password_secret_name = var.container_registry_pasword_secret_name
  }

  template {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    container {
      name   = "main-container"
      image  = var.container_image
      cpu    = var.cpu_requests
      memory = var.memory_requests

      dynamic "env" {
        for_each = var.container_env_variables
        content {
          name  = env.key
          value = env.value
        }
      }
      
      dynamic "env" {
        for_each = var.container_env_secrets
        content {
          name  = env.key
          secret_name = env.value
        }
      }
    }
  }

  dynamic "secret" {
        for_each = var.container_secrets
        content {
          name        = secret.key
           identity = "System"
          key_vault_secret_id = secret.value
        }
      }
  

  dynamic "ingress" {
    for_each = var.enable_ingress ? [1] : []
    content {
      allow_insecure_connections = false
      external_enabled          = true
      target_port               = var.target_port
      transport                 = "http"

      traffic_weight {
        percentage      = 100
        latest_revision = true
      }
    }
  }

  tags = var.tags
}

# Key Vault Access Policy for Container App Managed Identity
resource "azurerm_key_vault_access_policy" "container_app" {
  count        = var.key_vault_name != "" ? 1 : 0
  key_vault_id = data.azurerm_key_vault.existing[0].id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_container_app.main.identity[0].principal_id

  secret_permissions = [
    "Get",
    "List"
  ]

  depends_on = [azurerm_container_app.main]
}

# Data source for current Azure client configuration
data "azurerm_client_config" "current" {}
