<!-- BEGIN_TF_DOCS -->
# Startup example

This deploys the module in its simplest form.

```hcl
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

data "azurerm_client_config" "this" {}

module "counting" {
  source = "../.."

  container_app_environment_resource_id = azurerm_container_app_environment.example.id
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
  location      = azurerm_resource_group.test.location
  revision_mode = "Single"
  secrets = {
    facebook_secret = {
      name  = "facebook-secret"
      value = "very_secret"
    }
  }

  depends_on = [
    azurerm_resource_group.test,
  ]
}

module "dashboard" {
  source = "../.."

  container_app_environment_resource_id = azurerm_container_app_environment.example.id
  name                                  = local.dashboard_app_name
  resource_group_name                   = azurerm_resource_group.test.name
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
        startup_probe = [{
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
  enable_telemetry = false
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
  location = azurerm_resource_group.test.location
  managed_identities = {
    system_assigned = true
  }
  revision_mode = "Single"

  depends_on = [
    azurerm_resource_group.test,
  ]
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
- [random_id.container_name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) (resource)
- [random_id.env_name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) (resource)
- [random_id.rg_name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) (resource)
- [azurerm_client_config.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)

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

The following outputs are exported:

### <a name="output_dashboard_url"></a> [dashboard\_url](#output\_dashboard\_url)

Description: output "latest\_revision\_fqdn" { value = module.dashboard.latest\_revision\_fqdn }  output "latest\_revision\_name" { value = module.dashboard.latest\_revision\_name }

## Modules

The following Modules are called:

### <a name="module_counting"></a> [counting](#module\_counting)

Source: ../..

Version:

### <a name="module_dashboard"></a> [dashboard](#module\_dashboard)

Source: ../..

Version:

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->