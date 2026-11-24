mock_provider "azapi" {
  mock_data "azapi_client_config" {
    defaults = {
      id                       = "/subscriptions/00000000-0000-0000-0000-000000000000"
      object_id                = "55555555-5555-4555-8555-555555555555"
      subscription_id          = "00000000-0000-0000-0000-000000000000"
      subscription_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
      tenant_id                = "11111111-1111-1111-1111-111111111111"
    }
  }

  mock_resource "azapi_resource_action" {
    defaults = {
      output = {}
    }
  }
}

mock_provider "random" {
  mock_resource "random_uuid" {
    defaults = {
      result = "22222222-2222-4222-8222-222222222222"
    }
  }
}

override_data {
  target = data.azapi_resource.rg
  values = {
    exists   = true
    id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit"
    location = "eastus2"
    output   = {}
  }
}

override_data {
  target = data.azapi_resource.existing
  values = {
    exists = false
    id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit/providers/Microsoft.App/containerApps/ca-unit"
    output = {}
  }
}

override_resource {
  target = azapi_resource.container_app
  values = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit/providers/Microsoft.App/containerApps/ca-unit"
    output = {
      properties = {
        customDomainVerificationId = "unit-verification"
        latestReadyRevisionName    = "ca-unit--unit"
        latestRevisionName         = "ca-unit--unit"
        outboundIpAddresses        = ["192.0.2.1"]
      }
    }
  }
}

variables {
  container_app_environment_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit/providers/Microsoft.App/managedEnvironments/cae-unit"
  location                              = "westus2"
  name                                  = "ca-unit"
  resource_group_name                   = "rg-unit"
  auth_configs = {
    current = {
      name = "current"
      platform = {
        enabled = true
      }
    }
  }
  template = {
    containers = [{
      cpu    = 0.25
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      memory = "0.5Gi"
      name   = "app"
    }]
  }
}

run "default_telemetry_and_auth_config" {
  command = apply

  providers = {
    azapi  = azapi
    random = random
  }

  assert {
    condition     = var.enable_telemetry && length(azapi_resource.telemetry) == 1 && length(terraform_data.telemetry) == 1
    error_message = "Telemetry must remain enabled by default."
  }

  assert {
    condition = (
      azapi_resource.telemetry[0].location == var.location &&
      output.location == var.location &&
      azapi_resource.telemetry[0].location != data.azapi_resource.rg.location &&
      azapi_resource.telemetry[0].parent_id == "/subscriptions/00000000-0000-0000-0000-000000000000" &&
      azapi_resource.telemetry[0].type == "Microsoft.Resources/deployments@2025-04-01"
    )
    error_message = "Root telemetry must use the required region and active subscription."
  }

  assert {
    condition = (
      can(regex("^46d3xtrf\\.res\\.cc13c5f\\.[A-Za-z0-9_-]+\\.[togx]\\.[a-f0-9]{4}$", azapi_resource.telemetry[0].name)) &&
      length(azapi_resource.telemetry[0].name) <= 64 &&
      azapi_resource.telemetry[0].body.properties.mode == "Incremental" &&
      length(azapi_resource.telemetry[0].body.properties.template.resources) == 0 &&
      can(azapi_resource.telemetry[0].body.properties.template.outputs.apply_id.value)
    )
    error_message = "Telemetry must retain its metadata-backed valid name and empty incremental deployment."
  }

  assert {
    condition = (
      toset(keys(module.auth_config)) == toset(["current"]) &&
      module.auth_config["current"].name == "current" &&
      module.auth_config["current"].resource.parent_id == output.resource_id &&
      module.auth_config["current"].resource.type == "Microsoft.App/containerApps/authConfigs@2025-01-01" &&
      module.auth_config["current"].resource.body.properties.platform.enabled
    )
    error_message = "The keyed auth config must preserve its parent, resource name, API type and platform configuration."
  }

  assert {
    condition = (
      azapi_resource_action.post_creation_update.method == "PATCH" &&
      azapi_resource_action.post_creation_update.resource_id == output.resource_id
    )
    error_message = "The mocked post-creation PATCH must retain the container-app target."
  }
}

run "disabled_telemetry_with_auth_config" {
  command = apply

  providers = {
    azapi  = azapi
    random = random
  }

  variables {
    enable_telemetry = false
  }

  assert {
    condition     = length(azapi_resource.telemetry) == 0 && length(terraform_data.telemetry) == 0
    error_message = "Disabling telemetry must remove the root telemetry deployment and keeper."
  }

  assert {
    condition     = output.location == var.location && output.location != data.azapi_resource.rg.location
    error_message = "Location remains explicit and required when telemetry is disabled."
  }

  assert {
    condition = (
      toset(keys(module.auth_config)) == toset(["current"]) &&
      module.auth_config["current"].resource.parent_id == output.resource_id &&
      module.auth_config["current"].resource.body.properties.platform.enabled
    )
    error_message = "Disabling telemetry must not remove or alter the auth config."
  }
}
