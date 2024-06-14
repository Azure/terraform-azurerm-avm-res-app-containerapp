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
  name     = "example-container-app-${random_id.rg_name.hex}"
}

locals {
  counting_app_name  = "counting-${random_id.container_name.hex}"
  dashboard_app_name = "dashboard-${random_id.container_name.hex}"
}

resource "azurerm_container_app_environment" "example" {
  location            = azurerm_resource_group.test.location
  name                = "my-environment"
  resource_group_name = azurerm_resource_group.test.name
}

module "counting" {
  source                       = "../.."
  container_app_environment_id = azurerm_container_app_environment.example.id
  name                         = local.counting_app_name
  resource_group_name          = azurerm_resource_group.test.name
  revision_mode                = "Single"
  template = {
    containers = [
      {
        name   = "countingservicetest1"
        memory = "0.5Gi"
        cpu    = 0.25
        image  = "docker.io/hashicorp/counting-service:0.0.2"
        env = [
          {
            name  = "PORT"
            value = "9001"
          }
        ]
      },
    ]
  }
  ingress = {
    allow_insecure_connections = true
    external_enabled           = true
    target_port                = 9001
    traffic_weight = [{
      latest_revision = true
      percentage      = 100
    }]
  }
}

module "dashboard" {
  source                       = "../.."
  container_app_environment_id = azurerm_container_app_environment.example.id
  name                         = local.dashboard_app_name
  resource_group_name          = azurerm_resource_group.test.name
  revision_mode                = "Single"
  template = {
    containers = [
      {
        name   = "testdashboard"
        memory = "1Gi"
        cpu    = 0.5
        image  = "docker.io/hashicorp/dashboard-service:0.0.4"
        env = [
          {
            name  = "PORT"
            value = "8080"
          },
          {
            name  = "COUNTING_SERVICE_URL"
            value = "http://${local.counting_app_name}"
          }
        ]
      },
    ]
  }

  ingress = {
    allow_insecure_connections = false
    target_port                = 8080
    external_enabled           = true

    traffic_weight = [{
      latest_revision = true
      percentage      = 100
    }]
  }
  managed_identities = {
    system_assigned = true
  }
}

# module "container_apps" {
#   source                         = "../.."
#   resource_group_name            = azurerm_resource_group.test.name
#   location                       = var.location
#   container_app_environment_name = "example-env-${random_id.env_name.hex}"
#
#   container_apps = {
#     counting = {
#       name          = local.counting_app_name
#       revision_mode = "Single"
#
#       template = {
#         containers = [
#           {
#             name   = "countingservicetest1"
#             memory = "0.5Gi"
#             cpu    = 0.25
#             image  = "docker.io/hashicorp/counting-service:0.0.2"
#             env = [
#               {
#                 name  = "PORT"
#                 value = "9001"
#               }
#             ]
#           },
#         ]
#       }
#
#       ingress = {
#         allow_insecure_connections = true
#         external_enabled           = true
#         target_port                = 9001
#         traffic_weight = {
#           latest_revision = true
#           percentage      = 100
#         }
#       }
#     },
#     dashboard = {
#       name          = local.dashboard_app_name
#       revision_mode = "Single"
#
#       template = {
#         containers = [
#           {
#             name   = "testdashboard"
#             memory = "1Gi"
#             cpu    = 0.5
#             image  = "docker.io/hashicorp/dashboard-service:0.0.4"
#             env = [
#               {
#                 name  = "PORT"
#                 value = "8080"
#               },
#               {
#                 name  = "COUNTING_SERVICE_URL"
#                 value = "http://${local.counting_app_name}"
#               }
#             ]
#           },
#         ]
#       }
#
#       ingress = {
#         allow_insecure_connections = false
#         target_port                = 8080
#         external_enabled           = true
#
#         traffic_weight = {
#           latest_revision = true
#           percentage      = 100
#         }
#       }
#       identity = {
#         type = "SystemAssigned"
#       }
#     },
#   }
#   log_analytics_workspace_name = "testlaws"
# }