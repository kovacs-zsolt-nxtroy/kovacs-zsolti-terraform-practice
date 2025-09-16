# Scaling Rules for Container App
# This resource updates the existing container app with scaling configuration
resource "azapi_update_resource" "container_app_scaling" {
  type        = "Microsoft.App/containerApps@2023-05-01"
  resource_id = azurerm_container_app.main.id

  body = jsonencode({
    properties = {
      template = {
        scale = {
          minReplicas = var.min_replicas
          maxReplicas = var.max_replicas
          rules = concat(
            var.http_scaler_concurrent_requests > 0 ? [
              {
                name = "http-scaling-rule"
                http = {
                  metadata = {
                    concurrentRequests = tostring(var.http_scaler_concurrent_requests)
                  }
                }
              }
            ] : [],
            var.memory_scaling_threshold > 0 ? [
              {
                name = "memory-scaling"
                custom = {
                  type = "memory"
                  metadata = {
                    type  = "Utilization"
                    value = tostring(var.memory_scaling_threshold)
                  }
                }
              }
            ] : [],
            var.cpu_scaling_threshold > 0 ? [
              {
                name = "cpu-scaling"
                custom = {
                  type = "cpu"
                  metadata = {
                    type  = "Utilization"
                    value = tostring(var.cpu_scaling_threshold)
                  }
                }
              }
            ] : []
          )
        }
      }
    }
  })

  depends_on = [azurerm_container_app.main]
}
