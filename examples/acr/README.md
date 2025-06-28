<!-- BEGIN_TF_DOCS -->
# Startup example

This deploys the module with Azure Container Registry.

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

resource "null_resource" "docker_push" {
  provisioner "local-exec" {
    command = "docker login -u ${azurerm_container_registry_token.pushtoken.name} -p ${azurerm_container_registry_token_password.pushtokenpassword.password1[0].value} https://${azurerm_container_registry.acr.login_server}"
  }
  provisioner "local-exec" {
    command = "docker push ${docker_tag.nginx.target_image}"
  }
}

resource "azurerm_resource_group" "test" {
  location = var.location
  name     = "example-container-app-${random_id.rg_name.hex}"
}

resource "azurerm_virtual_network" "vnet" {
  location            = azurerm_resource_group.test.location
  name                = "virtualnetwork1"
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  address_prefixes                              = ["10.0.0.0/23"]
  name                                          = "subnet1"
  resource_group_name                           = azurerm_resource_group.test.name
  virtual_network_name                          = azurerm_virtual_network.vnet.name
  private_endpoint_network_policies             = "Disabled"
  private_link_service_network_policies_enabled = false
  service_endpoints                             = ["Microsoft.ContainerRegistry"]
}

resource "azurerm_private_endpoint" "pep" {
  location            = azurerm_resource_group.test.location
  name                = "mype"
  resource_group_name = azurerm_resource_group.test.name
  subnet_id           = azurerm_subnet.subnet.id

  private_service_connection {
    is_manual_connection           = false
    name                           = "countainerregistryprivatelink"
    private_connection_resource_id = azurerm_container_registry.acr.id
    subresource_names              = ["registry"]
  }
}

resource "azurerm_private_dns_zone" "pdz" {
  name                = "privatelink.azurecr.io"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnetlink_private" {
  name                  = "mydnslink"
  private_dns_zone_name = azurerm_private_dns_zone.pdz.name
  resource_group_name   = azurerm_resource_group.test.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

locals {
  acr_login_server = [
    for c in azurerm_private_endpoint.pep.custom_dns_configs : c.ip_addresses[0]
    if c.fqdn == "${azurerm_container_registry.acr.name}.azurecr.io"
    ][
    0
  ]
}

resource "azurerm_private_dns_a_record" "private" {
  name                = azurerm_container_registry.acr.name
  records             = [local.acr_login_server]
  resource_group_name = azurerm_resource_group.test.name
  ttl                 = 3600
  zone_name           = azurerm_private_dns_zone.pdz.name
}

locals {
  data_endpoint_ips = { for e in azurerm_private_endpoint.pep.custom_dns_configs : e.fqdn => e.ip_addresses[0] }
}

resource "azurerm_private_dns_a_record" "data" {
  name = "${azurerm_container_registry.acr.name}.${var.location}.data"
  records = [
    local.data_endpoint_ips["${azurerm_container_registry.acr.name}.${var.location}.data.azurecr.io"]
  ]
  resource_group_name = azurerm_resource_group.test.name
  ttl                 = 3600
  zone_name           = azurerm_private_dns_zone.pdz.name
}

resource "azurerm_container_registry" "acr" {
  #checkov:skip=CKV_AZURE_139: Public network access is required for the test
  #checkov:skip=CKV_AZURE_166: Quarantine would block our test so we skip it
  location                      = azurerm_resource_group.test.location
  name                          = "acr${random_id.container_name.hex}"
  resource_group_name           = azurerm_resource_group.test.name
  sku                           = "Premium"
  admin_enabled                 = false
  public_network_access_enabled = true
  retention_policy_in_days      = 7
  trust_policy_enabled          = true

  georeplications {
    location                = var.backup_location1
    tags                    = {}
    zone_redundancy_enabled = true
  }
  georeplications {
    location                = var.backup_location2
    tags                    = {}
    zone_redundancy_enabled = true
  }
  network_rule_set {
    default_action = "Allow"
  }
}

data "azurerm_container_registry_scope_map" "push_repos" {
  container_registry_name = azurerm_container_registry.acr.name
  name                    = "_repositories_push"
  resource_group_name     = azurerm_container_registry.acr.resource_group_name
}

data "azurerm_container_registry_scope_map" "pull_repos" {
  container_registry_name = azurerm_container_registry.acr.name
  name                    = "_repositories_pull"
  resource_group_name     = azurerm_container_registry.acr.resource_group_name
}

resource "azurerm_container_registry_token" "pushtoken" {
  container_registry_name = azurerm_container_registry.acr.name
  name                    = "pushtoken"
  resource_group_name     = azurerm_container_registry.acr.resource_group_name
  scope_map_id            = data.azurerm_container_registry_scope_map.push_repos.id
}

resource "azurerm_container_registry_token" "pulltoken" {
  container_registry_name = azurerm_container_registry.acr.name
  name                    = "pulltoken"
  resource_group_name     = azurerm_container_registry.acr.resource_group_name
  scope_map_id            = data.azurerm_container_registry_scope_map.pull_repos.id
}

resource "azurerm_container_registry_token_password" "pushtokenpassword" {
  container_registry_token_id = azurerm_container_registry_token.pushtoken.id

  password1 {
    expiry = timeadd(timestamp(), "24h")
  }

  lifecycle {
    ignore_changes = [password1]
  }
}

resource "azurerm_container_registry_token_password" "pulltokenpassword" {
  container_registry_token_id = azurerm_container_registry_token.pulltoken.id

  password1 {
    expiry = timeadd(timestamp(), "24h")
  }

  lifecycle {
    ignore_changes = [password1]
  }
}

resource "docker_image" "nginx" {
  name = "nginx:latest"
}

resource "docker_tag" "nginx" {
  source_image = docker_image.nginx.name
  target_image = "${azurerm_container_registry.acr.login_server}/${docker_image.nginx.name}"
}

resource "azurerm_container_app_environment" "example" {
  location                 = azurerm_resource_group.test.location
  name                     = "test-environment"
  resource_group_name      = azurerm_resource_group.test.name
  infrastructure_subnet_id = azurerm_subnet.subnet.id
}

module "container_apps" {
  source = "../.."

  container_app_environment_resource_id = azurerm_container_app_environment.example.id
  location                              = azurerm_resource_group.test.location
  name                                  = "nginx"
  resource_group_name                   = azurerm_resource_group.test.name
  template = {
    containers = [
      {
        name   = "nginx"
        memory = "0.5Gi"
        cpu    = 0.25
        image  = "${azurerm_container_registry.acr.login_server}/nginx"
      }
    ]
  }
  ingress = {
    allow_insecure_connections = false
    external_enabled           = true
    target_port                = 80
    traffic_weight = [
      {
        latest_revision = true
        percentage      = 100
      }
    ]
  }
  registries = [
    {
      server               = azurerm_container_registry.acr.login_server
      username             = azurerm_container_registry_token.pulltoken.name
      password_secret_name = "secname"
    }
  ]
  revision_mode = "Single"
  secrets = {
    nginx = {
      name  = "secname"
      value = azurerm_container_registry_token_password.pulltokenpassword.password1[0].value
    }
  }

  depends_on = [null_resource.docker_push]
}
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.9, < 2.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (>= 4.20.0, < 5.0)

- <a name="requirement_docker"></a> [docker](#requirement\_docker) (3.0.2)

- <a name="requirement_null"></a> [null](#requirement\_null) (>= 2.0.0)

- <a name="requirement_random"></a> [random](#requirement\_random) (>= 3.0.0)

## Resources

The following resources are used by this module:

- [azurerm_container_app_environment.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app_environment) (resource)
- [azurerm_container_registry.acr](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry) (resource)
- [azurerm_container_registry_token.pulltoken](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry_token) (resource)
- [azurerm_container_registry_token.pushtoken](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry_token) (resource)
- [azurerm_container_registry_token_password.pulltokenpassword](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry_token_password) (resource)
- [azurerm_container_registry_token_password.pushtokenpassword](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry_token_password) (resource)
- [azurerm_private_dns_a_record.data](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_a_record) (resource)
- [azurerm_private_dns_a_record.private](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_a_record) (resource)
- [azurerm_private_dns_zone.pdz](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) (resource)
- [azurerm_private_dns_zone_virtual_network_link.vnetlink_private](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) (resource)
- [azurerm_private_endpoint.pep](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) (resource)
- [azurerm_resource_group.test](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)
- [azurerm_subnet.subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) (resource)
- [azurerm_virtual_network.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) (resource)
- [docker_image.nginx](https://registry.terraform.io/providers/kreuzwerker/docker/3.0.2/docs/resources/image) (resource)
- [docker_tag.nginx](https://registry.terraform.io/providers/kreuzwerker/docker/3.0.2/docs/resources/tag) (resource)
- [null_resource.docker_push](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) (resource)
- [random_id.container_name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) (resource)
- [random_id.env_name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) (resource)
- [random_id.rg_name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) (resource)
- [azurerm_container_registry_scope_map.pull_repos](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/container_registry_scope_map) (data source)
- [azurerm_container_registry_scope_map.push_repos](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/container_registry_scope_map) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

No required inputs.

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_backup_location1"></a> [backup\_location1](#input\_backup\_location1)

Description: n/a

Type: `string`

Default: `"northeurope"`

### <a name="input_backup_location2"></a> [backup\_location2](#input\_backup\_location2)

Description: n/a

Type: `string`

Default: `"westeurope"`

### <a name="input_location"></a> [location](#input\_location)

Description: n/a

Type: `string`

Default: `"eastus"`

## Outputs

The following outputs are exported:

### <a name="output_app_url"></a> [app\_url](#output\_app\_url)

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