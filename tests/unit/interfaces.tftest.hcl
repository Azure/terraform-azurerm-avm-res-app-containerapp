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

  mock_data "azapi_resource" {
    defaults = {
      exists   = false
      id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit"
      location = "eastus2"
    }
  }

  mock_data "azapi_resource_list" {
    defaults = {
      output = {
        results = [{
          id        = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7"
          role_name = "Reader"
        }]
      }
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

run "defaults_and_explicit_location" {
  command = apply

  assert {
    condition     = output.location == var.location && output.location != data.azapi_resource.rg.location
    error_message = "The required location must reach the app independently of the resource-group lookup."
  }

  assert {
    condition     = length(azapi_resource.role_assignments) == 0 && length(azapi_resource.lock) == 0
    error_message = "Default interfaces must not create role assignments or a lock."
  }

  assert {
    condition     = output.identity == null ? true : length(output.identity) == 0
    error_message = "The default managed identity configuration must not add an identity."
  }
  providers = {
    azapi  = azapi
    random = random
  }
}

run "role_name_combined_identity_and_default_lock_name" {
  command = apply

  variables {
    location = "westus2"
    lock = {
      kind = "CanNotDelete"
    }
    managed_identities = {
      system_assigned            = true
      user_assigned_resource_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-unit"]
    }
    role_assignments = {
      reader = {
        description                = "Read the container app."
        principal_id               = "33333333-3333-4333-8333-333333333333"
        principal_type             = "ServicePrincipal"
        role_definition_id_or_name = "Reader"
      }
    }
  }

  assert {
    condition     = output.location == var.location
    error_message = "The required explicit location must reach the container app."
  }

  assert {
    condition = (
      toset(keys(azapi_resource.role_assignments)) == toset(["reader"]) &&
      azapi_resource.role_assignments["reader"].parent_id == output.resource_id &&
      azapi_resource.role_assignments["reader"].type == "Microsoft.Authorization/roleAssignments@2022-04-01" &&
      azapi_resource.role_assignments["reader"].name == "22222222-2222-4222-8222-222222222222"
    )
    error_message = "The role assignment must retain its map key and app scope and use the utility's generated UUID."
  }

  assert {
    condition = (
      azapi_resource.role_assignments["reader"].body.properties.principalId == var.role_assignments["reader"].principal_id &&
      azapi_resource.role_assignments["reader"].body.properties.principalType == "ServicePrincipal" &&
      azapi_resource.role_assignments["reader"].body.properties.description == var.role_assignments["reader"].description &&
      azapi_resource.role_assignments["reader"].body.properties.roleDefinitionId == "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7"
    )
    error_message = "Role-name lookup must preserve the principal, principal type, description, and resolved role definition."
  }

  assert {
    condition = (
      one(output.identity).type == "SystemAssigned, UserAssigned" &&
      toset(one(output.identity).identity_ids) == var.managed_identities.user_assigned_resource_ids
    )
    error_message = "Both system-assigned and user-assigned identities must reach the container app."
  }

  assert {
    condition = (
      length(azapi_resource.lock) == 1 &&
      azapi_resource.lock[0].name == "lock-ca-unit" &&
      azapi_resource.lock[0].parent_id == output.resource_id &&
      azapi_resource.lock[0].type == "Microsoft.Authorization/locks@2020-05-01" &&
      azapi_resource.lock[0].body.properties.level == "CanNotDelete"
    )
    error_message = "An unnamed lock must preserve its fallback name, level, type, and container-app scope."
  }
  providers = {
    azapi  = azapi
    random = random
  }
}

run "role_id_optional_fields_and_named_read_only_lock" {
  command = apply

  variables {
    lock = {
      kind = "ReadOnly"
      name = "explicit-lock"
    }
    managed_identities = {
      user_assigned_resource_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-unit"]
    }
    role_assignments = {
      conditional_reader = {
        condition                              = "(!(ActionMatches{'Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read'}))"
        condition_version                      = "2.0"
        delegated_managed_identity_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-delegated"
        principal_id                           = "44444444-4444-4444-8444-444444444444"
        role_definition_id_or_name             = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/2a2b9908-6ea1-4ae2-8e65-a410df84e7d1"
        skip_service_principal_aad_check       = true
      }
    }
  }

  assert {
    condition = (
      toset(keys(azapi_resource.role_assignments)) == toset(["conditional_reader"]) &&
      azapi_resource.role_assignments["conditional_reader"].body.properties.roleDefinitionId == var.role_assignments["conditional_reader"].role_definition_id_or_name &&
      azapi_resource.role_assignments["conditional_reader"].body.properties.principalId == var.role_assignments["conditional_reader"].principal_id &&
      azapi_resource.role_assignments["conditional_reader"].body.properties.condition == var.role_assignments["conditional_reader"].condition &&
      azapi_resource.role_assignments["conditional_reader"].body.properties.conditionVersion == "2.0" &&
      azapi_resource.role_assignments["conditional_reader"].body.properties.delegatedManagedIdentityResourceId == var.role_assignments["conditional_reader"].delegated_managed_identity_resource_id &&
      azapi_resource.role_assignments["conditional_reader"].body.properties.principalType == null &&
      azapi_resource.role_assignments["conditional_reader"].body.properties.description == null
    )
    error_message = "Explicit role IDs and optional role-assignment properties must pass through without name lookup or invented defaults."
  }

  assert {
    condition = (
      one(output.identity).type == "UserAssigned" &&
      toset(one(output.identity).identity_ids) == var.managed_identities.user_assigned_resource_ids
    )
    error_message = "A user-assigned identity must not implicitly enable a system-assigned identity."
  }

  assert {
    condition = (
      length(azapi_resource.lock) == 1 &&
      azapi_resource.lock[0].name == "explicit-lock" &&
      azapi_resource.lock[0].body.properties.level == "ReadOnly" &&
      azapi_resource.lock[0].parent_id == output.resource_id
    )
    error_message = "An explicit lock name and ReadOnly level must be preserved."
  }
  providers = {
    azapi  = azapi
    random = random
  }
}
