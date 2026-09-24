mock_provider "azapi" {
  mock_data "azapi_resource" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example"
    }
  }
}
mock_provider "modtm" {}
mock_provider "random" {}

variables {
  container_app_environment_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example/providers/Microsoft.App/managedEnvironments/example"
  name                                  = "example"
  resource_group_name                   = "example"
  location                              = "westeurope"
  enable_telemetry                      = false
  template = {
    min_replicas = 1
    max_replicas = 1
    containers = [{
      name   = "example"
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }]
  }
}

# A first create that fails in Azure leaves the app with no revision, so the
# response has no latestRevisionName or latestReadyRevisionName.
run "app_without_revision" {
  command = apply

  override_resource {
    target = azapi_resource.container_app
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example/providers/Microsoft.App/containerApps/example"
      output = {
        properties = {
          provisioningState          = "Failed"
          customDomainVerificationId = "example"
          outboundIpAddresses        = []
        }
      }
    }
  }

  assert {
    condition     = output.latest_revision_name == null && output.latest_ready_revision_name == null
    error_message = "Revision name outputs must be null when the app has no revision."
  }
}
