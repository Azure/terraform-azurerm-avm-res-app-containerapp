# Uses the real AzAPI provider (no Azure calls are made at plan time) so that
# the provider's schema validation of the request body runs against the
# Microsoft.App/containerApps API definition.
provider "azapi" {
  client_id                  = "00000000-0000-0000-0000-000000000000"
  client_secret              = "unit-test"
  skip_provider_registration = true
  subscription_id            = "00000000-0000-0000-0000-000000000000"
  tenant_id                  = "11111111-1111-1111-1111-111111111111"
  use_cli                    = false
  use_msi                    = false
}

override_data {
  target = data.azapi_client_config.current
  values = {
    subscription_id          = "00000000-0000-0000-0000-000000000000"
    subscription_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
    tenant_id                = "11111111-1111-1111-1111-111111111111"
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

variables {
  container_app_environment_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit/providers/Microsoft.App/managedEnvironments/cae-unit"
  enable_telemetry                      = false
  location                              = "westus2"
  name                                  = "ca-unit"
  resource_group_name                   = "rg-unit"
  managed_identities = {
    user_assigned_resource_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-unit"]
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

run "lifecycle_main_is_accepted" {
  command = plan

  variables {
    identity_settings = [{
      identity  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-unit"
      lifecycle = "Main"
    }]
  }

  assert {
    condition     = azapi_resource.container_app.body.properties.configuration.identitySettings[0].lifecycle == "Main"
    error_message = "lifecycle = \"Main\" must reach the request body."
  }
}

run "lifecycle_retain_is_rejected" {
  command = plan

  variables {
    identity_settings = [{
      identity  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-unit"
      lifecycle = "Retain"
    }]
  }

  expect_failures = [var.identity_settings]
}
