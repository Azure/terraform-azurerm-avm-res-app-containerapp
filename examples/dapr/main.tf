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

resource "azapi_resource" "managed_environment" {
  location  = azurerm_resource_group.this.location
  name      = module.naming.container_app_environment.name_unique
  parent_id = azurerm_resource_group.this.id
  type      = "Microsoft.App/managedEnvironments@2025-01-01"
  body = {
    properties = {
      appLogsConfiguration = {
        destination = "azure-monitor"
      }
    }
  }
}

# This is the module call
module "node_app" {
  source = "../../"

  container_app_environment_resource_id = azapi_resource.managed_environment.id
  location                              = azurerm_resource_group.this.location
  # source             = "Azure/avm-<res/ptn>-<name>/azurerm"
  name                = "${module.naming.container_app.name_unique}-node"
  resource_group_name = azurerm_resource_group.this.name
  template = {
    containers = [{
      image  = "dapriosamples/hello-k8s-node:latest"
      name   = "hello-k8s-node"
      cpu    = 0.5
      memory = "1.0Gi"
      env = [{
        name  = "APP_PORT"
        value = 3000
      }]
    }]
    min_replicas = 1
    max_replicas = 1
  }
  dapr = {
    enabled      = true
    app_id       = "nodeapp"
    app_protocol = "http"
    app_port     = 3000
  }
  ingress = {
    external_enabled = false
    target_port      = 3000
  }
}

module "python_app" {
  source = "../../"

  container_app_environment_resource_id = azapi_resource.managed_environment.id
  location                              = azurerm_resource_group.this.location
  # source             = "Azure/avm-<res/ptn>-<name>/azurerm"
  name                = "${module.naming.container_app.name_unique}-python"
  resource_group_name = azurerm_resource_group.this.name
  template = {
    containers = [{
      image  = "dapriosamples/hello-k8s-python:latest"
      name   = "hello-k8s-python"
      cpu    = 0.5
      memory = "1.0Gi"
    }]
    min_replicas = 1
    max_replicas = 1
  }
  dapr = {
    enabled = true
    app_id  = "pythonapp"
  }
}
