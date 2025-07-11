resource "random_string" "this" {
  length  = 8
  special = false
  upper   = false
}

resource "azurerm_resource_group" "test" {
  location = var.location
  name     = "example-container-app-${random_string.this.result}"
}

resource "azurerm_container_app_environment" "example" {
  location            = azurerm_resource_group.test.location
  name                = "test-${random_string.this.result}-env"
  resource_group_name = azurerm_resource_group.test.name
}

module "app" {
  source = "../.."

  container_app_environment_resource_id = azurerm_container_app_environment.example.id
  name                                  = "testapp"
  resource_group_name                   = azurerm_resource_group.test.name
  template = {
    containers = [
      {
        name   = "python-${random_string.this.result}-container"
        memory = "0.5Gi"
        cpu    = 0.25
        image  = "jackofallops/azure-containerapps-python-acctest:v0.0.1"
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
    external_enabled           = true
    target_port                = 5000
    transport                  = "http"
    traffic_weight = [{
      latest_revision = true
      percentage      = 100
    }]
  }
  location      = azurerm_resource_group.test.location
  revision_mode = "Single"
  secrets = {
    facebook_secret = {
      name  = "facebook-secret"
      value = "very_secret"
    }
  }
}
