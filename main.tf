locals {
  sensitive_body_present = try(nonsensitive(anytrue([for item in local.sensitive_inputs : item != null])), false)
  sensitive_inputs = [
    var.secrets
  ]
}

moved {
  from = azurerm_container_app.this
  to   = azapi_resource.container_app
}

resource "azapi_resource" "container_app" {
  location  = local.main_location
  name      = var.name
  parent_id = local.resource_group_id
  type      = "Microsoft.App/containerApps@2025-02-02-preview"
  body = {
    kind = var.kind
    properties = {
      configuration = {
        activeRevisionsMode = var.revision_mode
        dapr = var.dapr != null ? {
          appId              = var.dapr.app_id
          appPort            = var.dapr.app_port
          appProtocol        = var.dapr.app_protocol
          enableApiLogging   = var.dapr.enable_api_logging
          enabled            = var.dapr.enabled
          httpMaxRequestSize = var.dapr.http_max_request_size
          httpReadBufferSize = var.dapr.http_read_buffer_size
          logLevel           = var.dapr.log_level
        } : null
        identitySettings = var.identity_settings != null ? [
          for is in var.identity_settings : {
            identity  = is.identity
            lifecycle = is.lifecycle
          }
        ] : []
        ingress = var.ingress == null ? null : {
          allowInsecure         = var.ingress.allow_insecure_connections
          clientCertificateMode = try(title(var.ingress.client_certificate_mode), null)
          exposedPort           = var.ingress.exposed_port
          external              = var.ingress.external_enabled
          targetPort            = var.ingress.target_port
          transport             = title(var.ingress.transport)
          additionalPortMappings = var.ingress.additional_port_mappings != null ? [
            for apm in var.ingress.additional_port_mappings : {
              exposedPort = apm.exposed_port
              external    = apm.external
              targetPort  = apm.target_port
            }
          ] : null
          corsPolicy = var.ingress.cors_policy != null ? {
            for k, v in {
              allowCredentials = var.ingress.cors_policy.allow_credentials
              allowedHeaders   = var.ingress.cors_policy.allowed_headers
              allowedMethods   = var.ingress.cors_policy.allowed_methods
              allowedOrigins   = var.ingress.cors_policy.allowed_origins
              exposeHeaders    = var.ingress.cors_policy.expose_headers
              maxAge           = var.ingress.cors_policy.max_age
            } : k => v if v != null
          } : null
          customDomains = (var.ingress.custom_domain != null || length(var.ingress.custom_domains) > 0) ? concat(
            # Legacy single domain support (deprecated)
            var.ingress.custom_domain != null ? [
              {
                bindingType   = var.ingress.custom_domain.certificate_binding_type
                certificateId = var.ingress.custom_domain.certificate_id
                name          = var.ingress.custom_domain.name
              }
            ] : [],
            # New multiple domains support
            length(var.ingress.custom_domains) > 0 ? [
              for domain in var.ingress.custom_domains : {
                bindingType   = domain.certificate_binding_type
                certificateId = domain.certificate_id
                name          = domain.name
              }
            ] : []
          ) : null
          ipSecurityRestrictions = var.ingress.ip_restrictions != null ? [
            for ipr in var.ingress.ip_restrictions : {
              action         = ipr.action
              description    = ipr.description
              ipAddressRange = ipr.ip_range
              name           = ipr.name
            }
          ] : null
          stickySessions = var.ingress.sticky_sessions != null ? {
            affinity = var.ingress.sticky_sessions.affinity
          } : null
          traffic = [
            for weight in var.ingress.traffic_weight : {
              label          = weight.label
              latestRevision = weight.latest_revision
              revisionName   = weight.revision_suffix
              weight         = weight.percentage
            }
          ]
        }
        maxInactiveRevisions = var.max_inactive_revisions
        registries = var.registries != null ? [
          for reg in var.registries : {
            identity          = reg.identity == null ? "" : reg.identity
            passwordSecretRef = reg.password_secret_name
            server            = reg.server
            username          = reg.username
          }
        ] : null
        runtime = var.runtime != null ? {
          java = var.runtime.java != null ? {
            enableMetrics = var.runtime.java.enable_metrics
          } : null
        } : null
        service = var.service != null ? {
          type = var.service.type
        } : null
      }
      environmentId        = var.container_app_environment_resource_id
      managedEnvironmentId = var.container_app_environment_resource_id
      template = {
        containers = [
          for cont in var.template.containers : { for k, v in {
            args    = cont.args
            command = cont.command
            env = cont.env != null ? [
              for e in cont.env : { for k, v in {
                name      = e.name
                secretRef = e.secret_name
                value     = e.value
              } : k => v if v != null }
            ] : null
            image  = cont.image
            name   = cont.name
            probes = length(local.container_probes[cont.name]) > 0 ? local.container_probes[cont.name] : null
            resources = {
              cpu    = cont.cpu
              memory = cont.memory
            }
            volumeMounts = cont.volume_mounts != null ? [
              for vm in cont.volume_mounts : {
                mountPath  = vm.path
                subPath    = vm.sub_path
                volumeName = vm.name
              }
            ] : null
          } : k => v if v != null }
        ]
        initContainers = var.template.init_containers != null ? [
          for init_cont in var.template.init_containers : {
            args    = init_cont.args
            command = init_cont.command
            env = init_cont.env != null ? [
              for e in init_cont.env : { for k, v in {
                name      = e.name
                secretRef = e.secret_name
                value     = e.value
              } : k => v if v != null }
            ] : null
            image = init_cont.image
            name  = init_cont.name
            resources = { for k, v in {
              cpu    = init_cont.cpu
              memory = init_cont.memory
            } : k => v if v != null }
            volumeMounts = init_cont.volume_mounts != null ? [
              for vm in init_cont.volume_mounts : { for k, v in {
                mountPath  = vm.path
                subPath    = vm.sub_path
                volumeName = vm.name
              } : k => v if v != null }
            ] : null
          }
        ] : null
        revisionSuffix = var.template.revision_suffix
        scale = { for k, v in {
          minReplicas = var.template.min_replicas
          maxReplicas = var.template.max_replicas
          # Add missing scale properties
          cooldownPeriod  = var.template.cooldown_period
          pollingInterval = var.template.polling_interval
          rules           = length(local.scale_rules) > 0 ? local.scale_rules : null
        } : k => v if v != null }
        serviceBinds = var.template.service_binds != null ? [
          for sb in var.template.service_binds : { for k, v in {
            name      = sb.name
            serviceId = sb.service_id
          } : k => v if v != null }
        ] : null
        terminationGracePeriodSeconds = var.template.termination_grace_period_seconds
        volumes = var.template.volumes != null ? [
          for vol in var.template.volumes : {
            name         = vol.name
            storageType  = vol.storage_type
            storageName  = vol.storage_name
            mountOptions = vol.mount_options
            secrets = vol.secrets != null ? [
              for secret in vol.secrets : {
                path      = secret.path
                secretRef = secret.secret_name
              }
            ] : null
          }
        ] : []
      }
      workloadProfileName = var.workload_profile_name
    }
  }
  create_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers              = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values    = ["*"]
  schema_validation_enabled = false
  sensitive_body = local.sensitive_body_present ? {
    properties = {
      configuration = {
        secrets = var.secrets != null ? [
          for s in var.secrets : merge(
            {
              identity = s.identity
              name     = s.name
            },
            s.key_vault_secret_id != null ? { keyVaultUrl = s.key_vault_secret_id } : {},
            s.value != null ? { value = s.value } : {}
          )
        ] : null
    } }
  } : null
  tags           = var.tags
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  dynamic "identity" {
    for_each = module.avm_interfaces.managed_identities_azapi == null ? [] : [1]

    content {
      type         = module.avm_interfaces.managed_identities_azapi.type
      identity_ids = module.avm_interfaces.managed_identities_azapi.identity_ids
    }
  }
  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }

  lifecycle {
    ignore_changes = [
      body.properties.template.revisionSuffix,
      body.properties.managedEnvironmentId,
      schema_validation_enabled,
      response_export_values,
    ]
  }
}

# Read existing container app state to detect revision suffix changes.
# Uses static type and known inputs (no dependency on azapi_resource.container_app)
# so that `exists` is known at plan time even on first Create.
data "azapi_resource" "existing" {
  name                   = var.name
  parent_id              = data.azapi_resource.rg.id
  type                   = "Microsoft.App/containerApps@2025-07-01"
  ignore_not_found       = true
  response_export_values = ["*"]
}

locals {
  # HasChange guard for revision suffix:
  # - user didn't set suffix (null) → null (omit from update)
  # - resource doesn't exist yet (Create) → null (handled by main resource)
  # - resource exists and suffix changed → new value (send update)
  # - resource exists and suffix unchanged → null (skip update)
  existing_revision_suffix = (
    data.azapi_resource.existing.exists
    ? try(data.azapi_resource.existing.output.properties.template.revisionSuffix, null)
    : null
  )
  revision_suffix_to_send = (
    var.template.revision_suffix == null ? null :
    !data.azapi_resource.existing.exists ? null :
    var.template.revision_suffix != local.existing_revision_suffix ? var.template.revision_suffix :
    null
  )
}

# Track revision suffix changes to trigger post-creation update replacement
resource "terraform_data" "update_keeper" {
  input = var.template.revision_suffix
}

# Send revision suffix update only when user explicitly changes the suffix value.
# This avoids the "revision with suffix already exists" error caused by re-sending
# an unchanged suffix in the main resource PUT body.
resource "azapi_update_resource" "post_creation_update" {
  resource_id = azapi_resource.container_app.id
  type        = azapi_resource.container_app.type
  body = {
    properties = {
      template = {
        revisionSuffix = local.revision_suffix_to_send
      }
    }
  }
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  depends_on = [azapi_resource.container_app]

  lifecycle {
    ignore_changes       = all
    replace_triggered_by = [terraform_data.update_keeper]
  }
}
