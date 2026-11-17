mock_provider "azapi" {}

mock_provider "azurerm" {
  mock_data "azurerm_client_config" {
    defaults = {
      subscription_id = "00000000-0000-0000-0000-000000000000"
    }
  }

  mock_data "azurerm_container_registry_scope_map" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit/providers/Microsoft.ContainerRegistry/registries/acrf00dbabe/scopeMaps/_repositories_pull"
    }
  }

  mock_resource "azurerm_container_registry" {
    defaults = {
      id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit/providers/Microsoft.ContainerRegistry/registries/acrf00dbabe"
      login_server = "acrf00dbabe.azurecr.io"
    }
  }

  mock_resource "azurerm_container_registry_token" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit/providers/Microsoft.ContainerRegistry/registries/acrf00dbabe/tokens/pulltoken"
    }
  }

  mock_resource "azurerm_subnet" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit/providers/Microsoft.Network/virtualNetworks/vnet-unit/subnets/subnet-unit"
    }
  }

  mock_resource "azurerm_virtual_network" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit/providers/Microsoft.Network/virtualNetworks/vnet-unit"
    }
  }

  mock_resource "azurerm_private_endpoint" {
    defaults = {
      custom_dns_configs = [{
        fqdn         = "acrf00dbabe.azurecr.io"
        ip_addresses = ["10.0.0.4"]
        }, {
        fqdn         = "acrf00dbabe.eastus.data.azurecr.io"
        ip_addresses = ["10.0.0.5"]
      }]
    }
  }
}

mock_provider "random" {
  mock_resource "random_id" {
    defaults = {
      hex = "f00dbabe"
    }
  }
}

run "imports_nginx_into_the_authenticated_pull_registry" {
  command = apply

  providers = {
    azapi   = azapi
    azurerm = azurerm
    random  = random
  }

  variables {
    enable_telemetry = false
  }

  override_module {
    target = module.container_apps
    outputs = {
      fqdn_url = "https://nginx.example.test"
    }
  }

  assert {
    condition = (
      azapi_resource_action.import_nginx.resource_id == azurerm_container_registry.acr.id &&
      azapi_resource_action.import_nginx.type == "Microsoft.ContainerRegistry/registries@2023-07-01" &&
      azapi_resource_action.import_nginx.action == "importImage" &&
      azapi_resource_action.import_nginx.method == "POST" &&
      azapi_resource_action.import_nginx.when == "apply"
    )
    error_message = "The image must be imported through the target ACR's apply-time ARM action."
  }

  assert {
    condition = (
      azapi_resource_action.import_nginx.body.source.registryUri == "docker.io" &&
      azapi_resource_action.import_nginx.body.source.sourceImage == "library/nginx:latest" &&
      azapi_resource_action.import_nginx.body.targetTags == ["nginx:latest"] &&
      azapi_resource_action.import_nginx.body.mode == "Force"
    )
    error_message = "The import must preserve nginx:latest and allow an existing destination tag to be overwritten."
  }

  assert {
    condition = (
      azurerm_container_registry_token.pulltoken.scope_map_id == data.azurerm_container_registry_scope_map.pull_repos.id &&
      azurerm_container_registry_token_password.pulltokenpassword.container_registry_token_id == azurerm_container_registry_token.pulltoken.id
    )
    error_message = "Server-side import must retain the existing repository pull-token/password chain."
  }
}
