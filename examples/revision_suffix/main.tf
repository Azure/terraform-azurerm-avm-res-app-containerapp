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

resource "azurerm_container_app_environment" "example" {
  location            = azurerm_resource_group.test.location
  name                = "my-environment"
  resource_group_name = azurerm_resource_group.test.name
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
  revision_mode = "Multiple"

  depends_on = [
    azurerm_resource_group.test,
  ]
}

# Query the actual resource state from Azure after module applies
data "azapi_resource" "container_app" {
  name                   = module.container_app.name
  parent_id              = azurerm_resource_group.test.id
  type                   = "Microsoft.App/containerApps@2024-03-01"
  response_export_values = ["properties.template.revisionSuffix", "properties.latestRevisionName", "properties.latestReadyRevisionName"]

  depends_on = [module.container_app]
}
