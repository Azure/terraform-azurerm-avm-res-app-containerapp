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

resource "azurerm_container_app_environment" "example" {
  location            = azurerm_resource_group.test.location
  name                = "my-environment"
  resource_group_name = azurerm_resource_group.test.name
}

module "container_apps" {
  source                                = "../.."
  resource_group_name                   = azurerm_resource_group.test.name
  container_app_environment_resource_id = azurerm_container_app_environment.example.id
  name                                  = "app-with-init-container-${random_id.container_name.hex}"
  revision_mode                         = "Single"
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
  ingress = {
    allow_insecure_connections = false
    target_port                = 80
    external_enabled           = true

    traffic_weight = [{
      latest_revision = true
      percentage      = 100
    }]
  }
}