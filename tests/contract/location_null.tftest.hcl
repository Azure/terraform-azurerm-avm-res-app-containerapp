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

  mock_data "azapi_resource" {
    defaults = {
      exists   = false
      id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit"
      location = "eastus2"
      output   = {}
    }
  }

  mock_data "azapi_resource_list" {
    defaults = {
      output = { results = [] }
    }
  }

  mock_resource "azapi_resource" {
    defaults = {
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

variables {
  container_app_environment_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit/providers/Microsoft.App/managedEnvironments/cae-unit"
  enable_telemetry                      = false
  location                              = null
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

run "reject_null_location_even_when_telemetry_disabled" {
  command = plan

  providers = {
    azapi  = azapi
    random = random
  }
}
