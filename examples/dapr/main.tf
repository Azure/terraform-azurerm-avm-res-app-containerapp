# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.0"
}

locals {
  node_port = 3000
}

resource "azurerm_resource_group" "this" {
  location = "australiaeast"
  name     = module.naming.resource_group.name_unique
}

resource "azurerm_log_analytics_workspace" "this" {
  location            = azurerm_resource_group.this.location
  name                = module.naming.log_analytics_workspace.name_unique
  resource_group_name = azurerm_resource_group.this.name
  retention_in_days   = 30
  sku                 = "PerGB2018"
  tags = {
    Environment = "demo"
    Purpose     = "dapr-example"
  }
}

resource "azurerm_application_insights" "this" {
  application_type    = "web"
  location            = azurerm_resource_group.this.location
  name                = module.naming.application_insights.name_unique
  resource_group_name = azurerm_resource_group.this.name
  tags = {
    Environment = "demo"
    Purpose     = "dapr-example"
  }
  workspace_id = azurerm_log_analytics_workspace.this.id
}

resource "azapi_resource" "managed_environment" {
  location  = azurerm_resource_group.this.location
  name      = module.naming.container_app_environment.name_unique
  parent_id = azurerm_resource_group.this.id
  type      = "Microsoft.App/managedEnvironments@2025-01-01"
  body = {
    properties = {
      daprAIInstrumentationKey = azurerm_application_insights.this.instrumentation_key
      appLogsConfiguration = {
        destination = "log-analytics"
        logAnalyticsConfiguration = {
          customerId = azurerm_log_analytics_workspace.this.workspace_id
          sharedKey  = azurerm_log_analytics_workspace.this.primary_shared_key
        }
      }
    }
  }

  depends_on = [
    azurerm_log_analytics_workspace.this,
    azurerm_application_insights.this
  ]
}

resource "azurerm_storage_account" "this" {
  account_replication_type = "ZRS"
  account_tier             = "Standard"
  location                 = azurerm_resource_group.this.location
  name                     = module.naming.storage_account.name_unique
  resource_group_name      = azurerm_resource_group.this.name
  account_kind             = "StorageV2"
  tags = {
    Environment = "demo"
    Purpose     = "dapr-state-store"
  }
}

resource "azurerm_storage_container" "orders" {
  name                  = "orders"
  container_access_type = "private"
  storage_account_id    = azurerm_storage_account.this.id
}

resource "azurerm_user_assigned_identity" "nodeapp" {
  location            = azurerm_resource_group.this.location
  name                = module.naming.user_assigned_identity.name_unique
  resource_group_name = azurerm_resource_group.this.name
  tags = {
    Environment = "demo"
    Purpose     = "dapr-example"
  }
}

resource "azurerm_role_assignment" "storage_contributor" {
  principal_id         = azurerm_user_assigned_identity.nodeapp.principal_id
  scope                = azurerm_storage_account.this.id
  principal_type       = "ServicePrincipal"
  role_definition_name = "Storage Blob Data Contributor"
}

resource "azapi_resource" "dapr_statestore" {
  name      = "statestore"
  parent_id = azapi_resource.managed_environment.id
  type      = "Microsoft.App/managedEnvironments/daprComponents@2025-01-01"
  body = {
    properties = {
      componentType = "state.azure.blobstorage"
      version       = "v1"
      ignoreErrors  = false
      initTimeout   = "5s"
      metadata = [
        {
          name  = "accountName"
          value = azurerm_storage_account.this.name
        },
        {
          name  = "containerName"
          value = azurerm_storage_container.orders.name
        },
        {
          name  = "azureClientId"
          value = azurerm_user_assigned_identity.nodeapp.client_id
        }
      ]
      scopes = ["nodeapp"]
    }
  }

  depends_on = [
    azurerm_storage_account.this,
    azurerm_storage_container.orders,
    azurerm_user_assigned_identity.nodeapp,
    azurerm_role_assignment.storage_contributor
  ]
}

module "node_app" {
  source = "../../"

  container_app_environment_resource_id = azapi_resource.managed_environment.id
  name                                  = "${module.naming.container_app.name_unique}-node"
  resource_group_name                   = azurerm_resource_group.this.name
  template = {
    containers = [{
      image  = "dapriosamples/hello-k8s-node:latest"
      name   = "hello-k8s-node"
      cpu    = 0.5
      memory = "1Gi"
      env = [{
        name  = "APP_PORT"
        value = local.node_port
      }]
      readiness_probes = [{
        initial_delay_seconds = 5
        path                  = "/order"
        period_seconds        = 10
        port                  = local.node_port
        transport             = "HTTP"
      }]
    }]
    min_replicas = 1
    max_replicas = 1
  }
  dapr = {
    enabled      = true
    app_id       = "nodeapp"
    app_protocol = "http"
    app_port     = local.node_port
  }
  ingress = {
    external_enabled = false
    target_port      = local.node_port
  }
  location = azurerm_resource_group.this.location
  managed_identities = {
    user_assigned_resource_ids = [azurerm_user_assigned_identity.nodeapp.id]
  }

  depends_on = [
    azapi_resource.dapr_statestore
  ]
}

module "python_app" {
  source = "../../"

  container_app_environment_resource_id = azapi_resource.managed_environment.id
  name                                  = "${module.naming.container_app.name_unique}-python"
  resource_group_name                   = azurerm_resource_group.this.name
  template = {
    containers = [{
      image  = "dapriosamples/hello-k8s-python:latest"
      name   = "hello-k8s-python"
      cpu    = 0.5
      memory = "1Gi"
    }]
    min_replicas = 1
    max_replicas = 1
  }
  dapr = {
    enabled = true
    app_id  = "pythonapp"
  }
  location = azurerm_resource_group.this.location

  depends_on = [module.node_app]
}
