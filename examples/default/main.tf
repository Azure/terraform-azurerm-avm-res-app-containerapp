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
  # source  = "Azure/avm-res-app-containerapp/azurerm"
  # version = "0.6.0"
  source = "../.."

  container_app_environment_resource_id = azurerm_container_app_environment.example.id
  location                              = azurerm_resource_group.test.location
  name                                  = local.counting_app_name
  resource_group_name                   = azurerm_resource_group.test.name
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
        readiness_probes = [{
          initial_delay_seconds = 5
          path                  = "/health"
          period_seconds        = 10
          port                  = 9001
          transport             = "HTTP"
        }]
      },
    ]
  }
  auth_configs = {
    fake_facebook = {
      name = "current"
      global_validation = {
        unauthenticated_client_action = "AllowAnonymous"
      }
      identity_providers = {
        facebook = {
          registration = {
            app_id                  = "123"
            app_secret_setting_name = "facebook-secret"
          }
        }
      }
      platform = {
        enabled = true
      }
    }
  }
  ingress = {
    allow_insecure_connections = true
    client_certificate_mode    = "ignore"
    external_enabled           = true
    target_port                = 9001
    traffic_weight = [{
      latest_revision = true
      percentage      = 100
    }]
  }
  revision_mode = "Single"
  secrets = {
    facebook_secret = {
      name  = "facebook-secret"
      value = "very_secret"
    }
  }
}

output "mod1" {
  value = {
    fqdn_url = module.counting.fqdn_url
    resource_id = module.counting.resource_id
  }
}

output "mod2" {
  value = {
    fqdn_url = module.dashboard.fqdn_url
    resource_id = module.dashboard.resource_id
  }
}

module "dashboard" {
  # source  = "Azure/avm-res-app-containerapp/azurerm"
  # version = "0.6.0"
  source = "../.."

  container_app_environment_resource_id = azurerm_container_app_environment.example.id
  location                              = azurerm_resource_group.test.location
  name                                  = local.dashboard_app_name
  resource_group_name                   = azurerm_resource_group.test.name
  enable_telemetry = false
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
        liveness_probes = [{
          initial_delay_seconds = 5
          path                  = "/health"
          period_seconds        = 10
          port                  = 8080
          transport             = "HTTP"
        }]
        startup_probes = [{
          initial_delay_seconds = 5
          period_seconds        = 10
          transport             = "HTTP"
          path                  = "/health"
          port                  = 8080
          header = [
            {
              name  = "X-Random-Header"
              value = "test"
            }
          ]
        }]
      },
    ]
  }
  ingress = {
    allow_insecure_connections = false
    client_certificate_mode    = "ignore"
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
  revision_mode = "Single"
}
