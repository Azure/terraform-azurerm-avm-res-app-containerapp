<!-- BEGIN_TF_DOCS -->
# Startup example

This deploys the module in its simplest form.

```hcl
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
  revision_mode                         = "Single"
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
  secrets = {
    facebook_secret = {
      name  = "facebook-secret"
      value = "very_secret"
    }
  }
}
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.9, < 2.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (>= 4.20.0, < 5.0)

- <a name="requirement_random"></a> [random](#requirement\_random) (>= 3.0.0)

## Resources

The following resources are used by this module:

- [azurerm_container_app_environment.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app_environment) (resource)
- [azurerm_resource_group.test](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)
- [random_string.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) (resource)

<!-- markdownlint-disable MD013 -->
## Required Inputs

No required inputs.

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_location"></a> [location](#input\_location)

Description: n/a

Type: `string`

Default: `"eastus"`

## Outputs

No outputs.

## Modules

The following Modules are called:

### <a name="module_app"></a> [app](#module\_app)

Source: ../..

Version:

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->