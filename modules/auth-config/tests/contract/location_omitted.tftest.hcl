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

  mock_resource "azapi_resource" {
    defaults = {
      id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit/providers/Microsoft.App/containerApps/ca-unit/authConfigs/current"
      output = {}
    }
  }
}

variables {
  container_app_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit/providers/Microsoft.App/containerApps/ca-unit"
  enable_telemetry          = false
  name                      = "current"
}

run "reject_missing_location_even_when_telemetry_disabled" {
  command = plan

  providers = {
    azapi = azapi
  }
}
