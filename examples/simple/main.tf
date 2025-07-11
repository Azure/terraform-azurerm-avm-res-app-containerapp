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

# This is the module call
module "container_app" {
  source = "../../"

  container_app_environment_resource_id = azurerm_container_app_environment.this.id
  # source             = "Azure/avm-<res/ptn>-<name>/azurerm"
  name                = module.naming.container_app.name_unique
  resource_group_name = azurerm_resource_group.this.name
  template = {
    containers = [{
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      name   = "containerapps-helloworld"
      cpu    = "0.25"
      memory = "0.5Gi"
    }]
    min_replicas = 1
    max_replicas = 1
  }
  ingress = {
    external_enabled = true
    target_port      = 80
  }
  location = azurerm_resource_group.this.location
}
