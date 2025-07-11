# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.0"
}

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  location = "australiaeast"
  name     = module.naming.resource_group.name_unique
}

resource "azurerm_container_app_environment" "this" {
  location            = azurerm_resource_group.this.location
  name                = module.naming.container_app_environment.name_unique
  resource_group_name = azurerm_resource_group.this.name
}

locals {
  test_nginx_config = file("${path.module}/nginx.conf")
}

# This is the module call
module "container_app" {
  source = "../../"

  container_app_environment_resource_id = azurerm_container_app_environment.this.id
  name                                  = module.naming.container_app.name_unique
  resource_group_name                   = azurerm_resource_group.this.name
  template = {
    containers = [{
      image  = "nginx:alpine"
      name   = "nginx"
      cpu    = "0.25"
      memory = "0.5Gi"
      readiness_probes = [{
        initial_delay_seconds = 5
        path                  = "/health"
        period_seconds        = 10
        port                  = 80
        transport             = "HTTP"
      }]
      volume_mounts = [{
        name = "nginx-config"
        path = "/etc/nginx/conf.d"
      }]
    }]
    volumes = [{
      name         = "nginx-config"
      storage_type = "Secret"
      secrets = [{
        secret_name = "nginx-config"
        path        = "default.conf"
      }]
    }]
  }
  enable_telemetry = false
  ingress = {
    external_enabled = true
    target_port      = 80
    traffic_weight = [{
      latest_revision = true
      percentage      = 100
    }]
  }
  location      = azurerm_resource_group.this.location
  revision_mode = "Single"
  secrets = {
    nginx_config = {
      name  = "nginx-config"
      value = local.test_nginx_config
    }
  }
}
