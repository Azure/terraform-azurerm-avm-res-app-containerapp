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
  location                 = azurerm_resource_group.test.location
  name                     = "my-environment"
  resource_group_name      = azurerm_resource_group.test.name
  infrastructure_subnet_id = azurerm_subnet.subnet.id
}

resource "azurerm_virtual_network" "vnet" {
  address_space       = ["192.168.0.0/16"]
  location            = var.location
  name                = azurerm_resource_group.test.name
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "subnet" {
  address_prefixes     = ["192.168.0.0/16"]
  name                 = "container-app-subnet"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}

resource "azurerm_private_dns_zone" "private_dns_zone" {
  name                = azurerm_container_app_environment.example.default_domain
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnet_link" {
  name                  = "containerapplink"
  private_dns_zone_name = azurerm_private_dns_zone.private_dns_zone.name
  resource_group_name   = azurerm_resource_group.test.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

resource "azurerm_private_dns_a_record" "containerapp_record" {
  name                = local.dashboard_app_name
  records             = [azurerm_container_app_environment.example.static_ip_address]
  resource_group_name = azurerm_resource_group.test.name
  ttl                 = 300
  zone_name           = azurerm_private_dns_zone.private_dns_zone.name
}

module "counting" {
  source                                = "../.."
  container_app_environment_resource_id = azurerm_container_app_environment.example.id
  name                                  = local.counting_app_name
  resource_group_name                   = azurerm_resource_group.test.name
  revision_mode                         = "Single"
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
      },
    ]
  }
  ingress = {
    allow_insecure_connections = true
    external_enabled           = true
    target_port                = 9001
    traffic_weight = [{
      latest_revision = true
      percentage      = 100
    }]
  }
  depends_on = [azurerm_private_dns_a_record.containerapp_record, azurerm_private_dns_zone_virtual_network_link.vnet_link]
}

module "dashboard" {
  source                                = "../.."
  container_app_environment_resource_id = azurerm_container_app_environment.example.id
  name                                  = local.dashboard_app_name
  resource_group_name                   = azurerm_resource_group.test.name
  revision_mode                         = "Single"
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
      },
    ]
  }

  ingress = {
    allow_insecure_connections = false
    target_port                = 8080
    external_enabled           = true

    traffic_weight = [{
      latest_revision = true
      percentage      = 100
    }]
  }
  managed_identities = {
    system_assigned = true
  }
}

# module "container_apps" {
#   source                         = "../.."
#   resource_group_name            = azurerm_resource_group.test.name
#   location                       = var.location
#   container_app_environment_name = "example-env-${random_id.env_name.hex}"
#
#   container_apps = {
#     counting = {
#       name          = local.counting_app_name
#       revision_mode = "Single"
#
#       template = {
#         containers = [
#           {
#             name   = "countingservicetest1"
#             memory = "0.5Gi"
#             cpu    = 0.25
#             image  = "docker.io/hashicorp/counting-service:0.0.2"
#             env = [
#               {
#                 name  = "PORT"
#                 value = "9001"
#               }
#             ]
#           },
#         ]
#       }
#
#       ingress = {
#         allow_insecure_connections = true
#         external_enabled           = true
#         target_port                = 9001
#         traffic_weight = {
#           latest_revision = true
#           percentage      = 100
#         }
#       }
#     },
#     dashboard = {
#       name          = local.dashboard_app_name
#       revision_mode = "Single"
#
#       template = {
#         containers = [
#           {
#             name   = "testdashboard"
#             memory = "1Gi"
#             cpu    = 0.5
#             image  = "docker.io/hashicorp/dashboard-service:0.0.4"
#             env = [
#               {
#                 name  = "PORT"
#                 value = "8080"
#               },
#               {
#                 name  = "COUNTING_SERVICE_URL"
#                 value = "http://${local.counting_app_name}"
#               }
#             ]
#           },
#         ]
#       }
#
#       ingress = {
#         allow_insecure_connections = false
#         target_port                = 8080
#         external_enabled           = true
#
#         traffic_weight = {
#           latest_revision = true
#           percentage      = 100
#         }
#       }
#       identity = {
#         type = "SystemAssigned"
#       }
#     },
#   }
#   log_analytics_workspace_name = "testlaws"
# }
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.2)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (>= 3.11, < 4.0)

- <a name="requirement_random"></a> [random](#requirement\_random) (>= 3.0.0)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (>= 3.11, < 4.0)

- <a name="provider_random"></a> [random](#provider\_random) (>= 3.0.0)

## Resources

The following resources are used by this module:

- [azurerm_container_app_environment.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app_environment) (resource)
- [azurerm_private_dns_a_record.containerapp_record](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_a_record) (resource)
- [azurerm_private_dns_zone.private_dns_zone](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) (resource)
- [azurerm_private_dns_zone_virtual_network_link.vnet_link](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) (resource)
- [azurerm_resource_group.test](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)
- [azurerm_subnet.subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) (resource)
- [azurerm_virtual_network.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) (resource)
- [random_id.container_name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) (resource)
- [random_id.env_name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) (resource)
- [random_id.rg_name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) (resource)

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

Description: n/a

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