resource "random_id" "rg_name" {
  byte_length = 8
}

resource "random_id" "env_name" {
  byte_length = 8
}

resource "random_id" "container_name" {
  byte_length = 4
}

resource "docker_registry_image" "remote" {
  name          = docker_tag.nginx.target_image
  keep_remotely = true
  auth_config {
    address  = "https://${azurerm_container_registry.acr.login_server}"
    password = azurerm_container_registry_token_password.pushtokenpassword.password1[0].value
    username = azurerm_container_registry_token.pushtoken.name
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
  enable_telemetry = false
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

  depends_on = [docker_registry_image.remote]
}
