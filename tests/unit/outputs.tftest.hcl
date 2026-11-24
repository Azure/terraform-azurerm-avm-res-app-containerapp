mock_provider "azapi" {}

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
  template = {
    containers = [{
      cpu    = 0.25
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      memory = "0.5Gi"
      name   = "app"
    }]
  }
}

# A first create that fails in Azure leaves the app with no revision, so the response has no latestRevisionName or latestReadyRevisionName.
run "revision_names_are_null_without_revision" {
  command = apply

  override_resource {
    target = azapi_resource.container_app
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit/providers/Microsoft.App/containerApps/ca-unit"
      output = {
        properties = {
          customDomainVerificationId = "unit"
          outboundIpAddresses        = []
          provisioningState          = "Failed"
        }
      }
    }
  }

  assert {
    condition     = output.latest_revision_name == null && output.latest_ready_revision_name == null
    error_message = "Revision name outputs must be null when the app has no revision."
  }
}

run "revision_names_pass_through" {
  command   = apply
  state_key = "with_revision"

  override_resource {
    target = azapi_resource.container_app
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit/providers/Microsoft.App/containerApps/ca-unit"
      output = {
        properties = {
          customDomainVerificationId = "unit"
          latestReadyRevisionName    = "ca-unit--rev1"
          latestRevisionName         = "ca-unit--rev2"
          outboundIpAddresses        = []
          provisioningState          = "Succeeded"
        }
      }
    }
  }

  assert {
    condition     = output.latest_revision_name == "ca-unit--rev2" && output.latest_ready_revision_name == "ca-unit--rev1"
    error_message = "Revision name outputs must return the values Azure reports."
  }
}
