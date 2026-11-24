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
}

variables {
  container_app_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit/providers/Microsoft.App/containerApps/ca-unit"
  location                  = "westus2"
  name                      = "current"
  platform = {
    enabled = true
  }
}

run "explicit_location_and_default_telemetry" {
  command = apply

  providers = {
    azapi = azapi
  }

  assert {
    condition     = var.enable_telemetry && length(azapi_resource.telemetry) == 1 && length(terraform_data.telemetry) == 1
    error_message = "Direct auth-config telemetry must remain enabled by default."
  }

  assert {
    condition = (
      azapi_resource.telemetry[0].location == var.location &&
      azapi_resource.telemetry[0].parent_id == "/subscriptions/00000000-0000-0000-0000-000000000000" &&
      azapi_resource.telemetry[0].type == "Microsoft.Resources/deployments@2025-04-01" &&
      can(regex("^46d3xtrf\\.res\\.fb2418e\\.[A-Za-z0-9_-]+\\.[togx]\\.[a-f0-9]{4}$", azapi_resource.telemetry[0].name)) &&
      length(azapi_resource.telemetry[0].name) <= 64
    )
    error_message = "Auth telemetry must use its own metadata, required region and subscription deployment scope."
  }

  assert {
    condition = (
      output.name == "current" &&
      output.resource.parent_id == var.container_app_resource_id &&
      output.resource.type == "Microsoft.App/containerApps/authConfigs@2025-01-01" &&
      output.resource.body.properties.platform.enabled
    )
    error_message = "The owning module must preserve auth resource name, parent and body."
  }
}

run "explicit_location_with_disabled_telemetry" {
  command = apply

  providers = {
    azapi = azapi
  }

  variables {
    enable_telemetry = false
  }

  assert {
    condition     = length(azapi_resource.telemetry) == 0 && length(terraform_data.telemetry) == 0
    error_message = "The direct auth-config opt-out must remove its telemetry resources."
  }

  assert {
    condition     = output.resource.parent_id == var.container_app_resource_id && output.resource.body.properties.platform.enabled
    error_message = "Telemetry opt-out must preserve the auth resource."
  }
}
