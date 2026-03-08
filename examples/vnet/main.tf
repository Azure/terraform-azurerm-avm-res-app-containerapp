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

data "azurerm_client_config" "current" {}

resource "azapi_resource_action" "register_microsoft_app" {
  action      = "/providers/Microsoft.App/register"
  method      = "POST"
  resource_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  type        = "Microsoft.Resources/subscriptions@2021-04-01"
}

resource "azurerm_container_app_environment" "example" {
  location                 = azurerm_resource_group.test.location
  name                     = "my-environment"
  resource_group_name      = azurerm_resource_group.test.name
  infrastructure_subnet_id = azurerm_subnet.subnet.id

  depends_on = [azapi_resource_action.register_microsoft_app]

  lifecycle {
    ignore_changes = [
      infrastructure_resource_group_name,
      workload_profile
    ]
  }
}

resource "azurerm_virtual_network" "vnet" {
  location            = var.location
  name                = azurerm_resource_group.test.name
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["192.168.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  address_prefixes     = ["192.168.0.0/16"]
  name                 = "container-app-subnet"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.vnet.name

  delegation {
    name = "Microsoft.App.environments"

    service_delegation {
      name    = "Microsoft.App/environments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
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
      },
    ]
  }
  enable_telemetry = false
  ingress = {
    allow_insecure_connections = true
    external_enabled           = true
    target_port                = 9001
    traffic_weight = [{
      latest_revision = true
      percentage      = 100
    }]
  }
  location              = azurerm_resource_group.test.location
  resource_group_id     = azurerm_resource_group.test.id
  revision_mode         = "Single"
  workload_profile_name = "Consumption"

  depends_on = [azurerm_private_dns_a_record.containerapp_record, azurerm_private_dns_zone_virtual_network_link.vnet_link]
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
      },
    ]
  }
  enable_telemetry = false
  ingress = {
    allow_insecure_connections = false
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
  resource_group_id     = azurerm_resource_group.test.id
  revision_mode         = "Single"
  workload_profile_name = "Consumption"

  depends_on = [azurerm_private_dns_a_record.containerapp_record, azurerm_private_dns_zone_virtual_network_link.vnet_link]
}
