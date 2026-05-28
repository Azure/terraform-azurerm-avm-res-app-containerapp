module "auth_config" {
  source   = "./modules/auth-config"
  for_each = var.auth_configs

  container_app_resource_id = azapi_resource.container_app.id
  name                      = each.value.name
  enable_telemetry          = var.enable_telemetry
  encryption_settings       = each.value.encryption_settings
  global_validation         = each.value.global_validation
  http_settings             = each.value.http_settings
  identity_providers        = each.value.identity_providers
  login                     = each.value.login
  platform                  = each.value.platform
  retry                     = var.retry
  timeouts                  = var.timeouts
}

moved {
  from = azapi_resource.auth_config
  to   = module.auth_config.azapi_resource.this
}
