resource "random_id" "rg_name" {
  byte_length = 8
}

resource "random_id" "env_name" {
  byte_length = 8
}

resource "random_id" "container_name" {
  byte_length = 4
}

resource "azurerm_resource_group" "test" {
  location = var.location
  name     = "example-container-app-${random_id.rg_name.hex}-init-container"
}

data "azurerm_client_config" "current" {}

resource "azapi_resource_action" "register_microsoft_app" {
  action      = "/providers/Microsoft.App/register"
  method      = "POST"
  resource_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  type        = "Microsoft.Resources/subscriptions@2021-04-01"
}

resource "azurerm_container_app_environment" "example" {
  location            = azurerm_resource_group.test.location
  name                = "my-environment"
  resource_group_name = azurerm_resource_group.test.name

  depends_on = [azapi_resource_action.register_microsoft_app]
}

module "container_apps" {
  source = "../.."

  container_app_environment_resource_id = azurerm_container_app_environment.example.id
  name                                  = "app-with-init-container-${random_id.container_name.hex}"
  resource_group_name                   = azurerm_resource_group.test.name
  template = {
    init_containers = [
      {
        name   = "debian"
        image  = "debian:latest"
        memory = "0.5Gi"
        cpu    = 0.25
        command = [
          "/bin/sh",
        ]
        args = [
          "-c", "echo Hello from the debian container > /shared/index.html"
        ]
        volume_mounts = [
          {
            name = "shared"
            path = "/shared"
          }
        ]
      }
    ],
    containers = [
      {
        name   = "nginx"
        image  = "nginx:latest"
        memory = "1Gi"
        cpu    = 0.5
        volume_mounts = [{
          name = "shared"
          path = "/usr/share/nginx/html"
        }]
      }
    ],
    volumes = [
      {
        name         = "shared"
        storage_type = "EmptyDir"
      }
    ]
  }
  enable_telemetry = false
  ingress = {
    allow_insecure_connections = false
    target_port                = 80
    external_enabled           = true

    traffic_weight = [{
      latest_revision = true
      percentage      = 100
    }]
  }
  location          = azurerm_resource_group.test.location
  resource_group_id = azurerm_resource_group.test.id
  revision_mode     = "Single"
}
