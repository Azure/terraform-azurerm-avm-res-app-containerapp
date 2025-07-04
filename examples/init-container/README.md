<!-- BEGIN_TF_DOCS -->
# Startup example

This deploys the module with init container.

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
  name     = "example-container-app-${random_id.rg_name.hex}-init-container"
}

resource "azurerm_container_app_environment" "example" {
  location            = azurerm_resource_group.test.location
  name                = "my-environment"
  resource_group_name = azurerm_resource_group.test.name
}

module "container_apps" {
  source = "../.."

  container_app_environment_resource_id = azurerm_container_app_environment.example.id
  location                              = azurerm_resource_group.test.location
  name                                  = "app-with-init-container-${random_id.container_name.hex}"
  resource_group_name                   = azurerm_resource_group.test.name
  template = {
    init_containers = [
      {
        name   = "debian"
        image  = "debian:latest"
        memory = "0.5Gi"
        cpu    = 0.25
        command = [
          "/bin/sh",
        ]
        args = [
          "-c", "echo Hello from the debian container > /shared/index.html"
        ]
        volume_mounts = [
          {
            name = "shared"
            path = "/shared"
          }
        ]
      }
    ],
    containers = [
      {
        name   = "nginx"
        image  = "nginx:latest"
        memory = "1Gi"
        cpu    = 0.5
        volume_mounts = [{
          name = "shared"
          path = "/usr/share/nginx/html"
        }]
      }
    ],
    volumes = [
      {
        name         = "shared"
        storage_type = "EmptyDir"
      }
    ]
  }
  ingress = {
    allow_insecure_connections = false
    target_port                = 80
    external_enabled           = true

    traffic_weight = [{
      latest_revision = true
      percentage      = 100
    }]
  }
  revision_mode = "Single"
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

### <a name="output_url"></a> [url](#output\_url)

Description: n/a

## Modules

The following Modules are called:

### <a name="module_container_apps"></a> [container\_apps](#module\_container\_apps)

Source: ../..

Version:

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->