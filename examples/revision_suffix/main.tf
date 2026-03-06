resource "random_id" "rg_name" {
  byte_length = 8
}

resource "random_id" "container_name" {
  byte_length = 4
}

resource "azurerm_resource_group" "test" {
  location = var.location
  name     = "example-revision-suffix-${random_id.rg_name.hex}"
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

module "container_app" {
  source = "../.."

  container_app_environment_resource_id = azurerm_container_app_environment.example.id
  name                                  = "app-${random_id.container_name.hex}"
  resource_group_name                   = azurerm_resource_group.test.name
  template = {
    revision_suffix = var.revision_suffix
    containers = [
      {
        name   = "myapp"
        memory = "0.5Gi"
        cpu    = 0.25
        image  = var.container_image
      },
    ]
  }
  enable_telemetry = false
  ingress = {
    allow_insecure_connections = true
    external_enabled           = true
    target_port                = 80
    traffic_weight = [{
      latest_revision = true
      percentage      = 100
    }]
  }
  location          = azurerm_resource_group.test.location
  resource_group_id = azurerm_resource_group.test.id
  revision_mode     = "Multiple"

  depends_on = [
    azurerm_resource_group.test,
  ]
}
