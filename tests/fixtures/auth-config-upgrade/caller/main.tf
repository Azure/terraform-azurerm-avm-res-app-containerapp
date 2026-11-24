terraform {
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.12"
    }
  }
}

locals {
  configs = {
    alpha = "alpha"
    beta  = "beta"
  }
  parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit/providers/Microsoft.App/containerApps/ca-unit"
}

resource "azapi_resource" "auth_config" {
  for_each = var.legacy ? local.configs : {}

  name      = each.value
  parent_id = local.parent_id
  type      = "Microsoft.App/containerApps/authConfigs@2025-01-01"
  body = {
    properties = {
      platform           = null
      encryptionSettings = {}
      globalValidation   = null
      identityProviders  = null
      login              = null
      httpSettings       = null
    }
  }
  ignore_null_property = true
}

module "auth_config" {
  source   = "../../../../modules/auth-config"
  for_each = var.legacy ? {} : local.configs

  container_app_resource_id = local.parent_id
  name                      = each.value
  enable_telemetry          = false
}

output "ids" {
  value = var.legacy ? {
    for key, resource in azapi_resource.auth_config : key => resource.id
    } : {
    for key, child in module.auth_config : key => child.resource_id
  }
}
