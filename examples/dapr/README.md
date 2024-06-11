<!-- BEGIN_TF_DOCS -->
# Startup example

This deploys the module with Dapr component.

```hcl
resource "random_id" "rg_name" {
  byte_length = 8
}

resource "random_id" "env_name" {
  byte_length = 8
}

resource "random_id" "keyvault_name" {
  byte_length = 8
}

resource "random_id" "sa_name" {
  byte_length = 4
}

resource "random_id" "container_name" {
  byte_length = 4
}

resource "azurerm_resource_group" "rg" {
  location = var.location
  name     = "rg-${random_id.rg_name.hex}"
}

data "azurerm_client_config" "current" {}

data "curl" "public_ip" {
  http_method = "GET"
  uri         = "https://api.ipify.org?format=json"
}

locals {
  public_ip = jsondecode(data.curl.public_ip.response).ip
}

resource "azurerm_key_vault" "test" {
  location                 = azurerm_resource_group.rg.location
  name                     = "testkv${random_id.keyvault_name.hex}"
  resource_group_name      = azurerm_resource_group.rg.name
  sku_name                 = "premium"
  tenant_id                = data.azurerm_client_config.current.tenant_id
  purge_protection_enabled = true

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
    ip_rules       = [local.public_ip, "0.0.0.0/0"]
  }

  depends_on = [azurerm_storage_container.test]
}

resource "azurerm_key_vault_key" "test" {
  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey"
  ]
  key_type        = "RSA-HSM"
  key_vault_id    = azurerm_key_vault.test.id
  name            = "testkey"
  expiration_date = timeadd("${formatdate("YYYY-MM-DD", timestamp())}T00:00:00Z", "168h")
  key_size        = 2048

  depends_on = [azurerm_key_vault_access_policy.client]

  lifecycle {
    ignore_changes = [expiration_date]
  }
}

resource "azurerm_log_analytics_workspace" "test" {
  location            = azurerm_resource_group.rg.location
  name                = "testlaworkspace"
  resource_group_name = azurerm_resource_group.rg.name
  retention_in_days   = 30
  sku                 = "PerGB2018"
}

resource "azurerm_key_vault_access_policy" "storage" {
  key_vault_id = azurerm_key_vault.test.id
  object_id    = azurerm_storage_account.test.identity[0].principal_id
  tenant_id    = azurerm_storage_account.test.identity[0].tenant_id
  key_permissions = [
    "Get",
    "Create",
    "List",
    "Restore",
    "Recover",
    "UnwrapKey",
    "WrapKey",
    "Purge",
    "Encrypt",
    "Decrypt",
    "Sign",
    "Verify",
    "GetRotationPolicy",
    "SetRotationPolicy"
  ]
  secret_permissions = [
    "Backup",
    "Delete",
    "Get",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Set"
  ]
  storage_permissions = [
    "Get",
    "List",
    "Set",
    "Update",
    "RegenerateKey",
    "Recover",
    "Purge"
  ]
}

resource "azurerm_key_vault_access_policy" "client" {
  key_vault_id = azurerm_key_vault.test.id
  object_id    = coalesce(var.msi_id, data.azurerm_client_config.current.object_id)
  tenant_id    = data.azurerm_client_config.current.tenant_id
  key_permissions = [
    "Get",
    "Create",
    "Delete",
    "List",
    "Restore",
    "Recover",
    "UnwrapKey",
    "WrapKey",
    "Purge",
    "Encrypt",
    "Decrypt",
    "Sign",
    "Verify",
    "GetRotationPolicy",
    "SetRotationPolicy"
  ]
  secret_permissions = [
    "Backup",
    "Delete",
    "Get",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Set"
  ]
  storage_permissions = [
    "Get",
    "List",
    "Set",
    "Update",
    "RegenerateKey",
    "Recover",
    "Purge"
  ]
}

resource "azurerm_storage_account" "test" {
  account_replication_type = "RAGRS"
  account_tier             = "Standard"
  location                 = azurerm_resource_group.rg.location
  name                     = "testsa${random_id.sa_name.hex}"
  resource_group_name      = azurerm_resource_group.rg.name
  min_tls_version          = "TLS1_2"

  identity {
    type = "SystemAssigned"
  }
  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
    ip_rules       = ["0.0.0.0/0"]
  }
  queue_properties {
    logging {
      delete  = true
      read    = true
      version = "1.0"
      write   = true
    }
  }

  lifecycle {
    ignore_changes = [customer_managed_key]
  }
}

resource "azurerm_log_analytics_storage_insights" "test" {
  name                 = "teststorageinsights"
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_id   = azurerm_storage_account.test.id
  storage_account_key  = azurerm_storage_account.test.primary_access_key
  workspace_id         = azurerm_log_analytics_workspace.test.id
  blob_container_names = ["blobExample"]
}

resource "azurerm_storage_account_customer_managed_key" "managedkey" {
  key_name           = azurerm_key_vault_key.test.name
  storage_account_id = azurerm_storage_account.test.id
  key_vault_id       = azurerm_key_vault.test.id
  key_version        = azurerm_key_vault_key.test.version

  depends_on = [azurerm_key_vault_access_policy.storage]
}

resource "azurerm_storage_container" "test" {
  #checkov:skip=CKV2_AZURE_21:lll
  name                  = "testcontainer"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_user_assigned_identity" "test" {
  location            = azurerm_resource_group.rg.location
  name                = "testidentity"
  resource_group_name = azurerm_resource_group.rg.name
}

module "containerapps" {
  source                         = "../.."
  resource_group_name            = azurerm_resource_group.rg.name
  location                       = azurerm_resource_group.rg.location
  container_app_environment_name = "example-env-${random_id.env_name.hex}"
  container_app_environment_tags = {
    environment = "test"
  }
  log_analytics_workspace = {
    id = azurerm_log_analytics_workspace.test.id
  }
  log_analytics_workspace_name = "testlaworkspace"

  dapr_component = {
    statestore = {
      name           = "statestore-${random_id.container_name.hex}"
      component_type = "state.azure.blobstorage"
      version        = "v1"
      scopes         = ["nodeapp"]
      metadata = [
        {
          name  = "accountName"
          value = azurerm_storage_account.test.name
        },
        {
          name  = "containerName"
          value = azurerm_storage_container.test.name
        },
        {
          name  = "azureClientId"
          value = azurerm_user_assigned_identity.test.client_id
        }
      ]
    }
  }
  container_apps = {
    pythonapp = {
      name          = "pythonapp-${random_id.container_name.hex}"
      revision_mode = "Single"

      template = {
        containers = [
          {
            name   = "pythonapp"
            cpu    = 0.25
            image  = "dapriosamples/hello-k8s-python:latest"
            memory = "0.5Gi"
          }
        ]
      }
      dapr = {
        app_id   = "pythonapp"
        app_port = 0
      }
      tags = {
        "environment" = "dev"
      }
    },
    nodeapp = {
      name          = "nodeapp-${random_id.container_name.hex}"
      revision_mode = "Single"

      template = {
        containers = [
          {
            name   = "nodeapp"
            cpu    = 0.25
            image  = "dapriosamples/hello-k8s-node:latest"
            memory = "0.5Gi"
            env = [
              {
                name  = "APP_PORT"
                value = "3000"
              }
            ]
          }
        ]
      }
      dapr = {
        app_id   = "nodeapp"
        app_port = 3000
      }
      identity = {
        type         = "UserAssigned"
        identity_ids = [azurerm_user_assigned_identity.test.id]
      }
    }
  }
}
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.2)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (>= 3.11, < 4.0)

- <a name="requirement_curl"></a> [curl](#requirement\_curl) (1.0.2)

- <a name="requirement_random"></a> [random](#requirement\_random) (>= 3.0.0)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (>= 3.11, < 4.0)

- <a name="provider_curl"></a> [curl](#provider\_curl) (1.0.2)

- <a name="provider_random"></a> [random](#provider\_random) (>= 3.0.0)

## Resources

The following resources are used by this module:

- [azurerm_key_vault.test](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) (resource)
- [azurerm_key_vault_access_policy.client](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) (resource)
- [azurerm_key_vault_access_policy.storage](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) (resource)
- [azurerm_key_vault_key.test](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_key) (resource)
- [azurerm_log_analytics_storage_insights.test](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_storage_insights) (resource)
- [azurerm_log_analytics_workspace.test](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) (resource)
- [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)
- [azurerm_storage_account.test](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) (resource)
- [azurerm_storage_account_customer_managed_key.managedkey](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_customer_managed_key) (resource)
- [azurerm_storage_container.test](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) (resource)
- [azurerm_user_assigned_identity.test](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) (resource)
- [random_id.container_name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) (resource)
- [random_id.env_name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) (resource)
- [random_id.keyvault_name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) (resource)
- [random_id.rg_name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) (resource)
- [random_id.sa_name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) (resource)
- [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)
- [curl_curl.public_ip](https://registry.terraform.io/providers/anschoewe/curl/1.0.2/docs/data-sources/curl) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

No required inputs.

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_location"></a> [location](#input\_location)

Description: n/a

Type: `string`

Default: `"eastus"`

### <a name="input_msi_id"></a> [msi\_id](#input\_msi\_id)

Description: n/a

Type: `string`

Default: `null`

## Outputs

No outputs.

## Modules

The following Modules are called:

### <a name="module_containerapps"></a> [containerapps](#module\_containerapps)

Source: ../..

Version:

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->