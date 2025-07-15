<!-- BEGIN_TF_DOCS -->
# Distributed Application Runtime (Dapr) example

This deploys the two containers used in this [Microsoft Learn tutorial](https://learn.microsoft.com/en-us/azure/container-apps/microservices-dapr?tabs=bash%2Cazure-cli).

The above tutorial uses the template here: <https://github.com/Azure-Samples/Tutorial-Deploy-Dapr-Microservices-ACA/blob/main/azuredeploy.bicep>.

```hcl
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
        initial_delay  = 5
        path           = "/order"
        period_seconds = 10
        port           = local.node_port
        transport      = "HTTP"
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
  enable_telemetry = false
  ingress = {
    external_enabled = false
    target_port      = local.node_port
    traffic_weight = [{
      latest_revision = true
      percentage      = 100
    }]
  }
  managed_identities = {
    user_assigned_resource_ids = [azurerm_user_assigned_identity.nodeapp.id]
  }
  revision_mode = "Single"

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
  enable_telemetry  = false
  location          = azurerm_resource_group.this.location
  resource_group_id = azurerm_resource_group.this.id
  revision_mode     = "Single"

  depends_on = [module.node_app]
}
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.9, < 2.0)

- <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) (>= 2.4.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (>= 4.20.0, < 5.0)

## Resources

The following resources are used by this module:

- [azapi_resource.dapr_statestore](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) (resource)
- [azapi_resource.managed_environment](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) (resource)
- [azurerm_application_insights.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights) (resource)
- [azurerm_log_analytics_workspace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) (resource)
- [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)
- [azurerm_role_assignment.storage_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_storage_account.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) (resource)
- [azurerm_storage_container.orders](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) (resource)
- [azurerm_user_assigned_identity.nodeapp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) (resource)

<!-- markdownlint-disable MD013 -->
## Required Inputs

No required inputs.

## Optional Inputs

No optional inputs.

## Outputs

No outputs.

## Modules

The following Modules are called:

### <a name="module_naming"></a> [naming](#module\_naming)

Source: Azure/naming/azurerm

Version: 0.4.0

### <a name="module_node_app"></a> [node\_app](#module\_node\_app)

Source: ../../

Version:

### <a name="module_python_app"></a> [python\_app](#module\_python\_app)

Source: ../../

Version:

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->