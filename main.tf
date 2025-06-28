resource "azapi_resource" "container_app" {
  location  = var.location
  name      = var.name
  parent_id = local.resource_group_id
  type      = "Microsoft.App/containerApps@2025-01-01"
  body = {
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
        ] : null
        ingress = var.ingress != null ? {
          allowInsecure         = var.ingress.allow_insecure_connections
          clientCertificateMode = var.ingress.client_certificate_mode
          exposedPort           = var.ingress.exposed_port
          external              = var.ingress.external_enabled
          targetPort            = var.ingress.target_port
          transport             = var.ingress.transport
          additionalPortMappings = var.ingress.additional_port_mappings != null ? [
            for apm in var.ingress.additional_port_mappings : {
              exposedPort = apm.exposed_port
              external    = apm.external
              targetPort  = apm.target_port
            }
          ] : null
          corsPolicy = var.ingress.cors_policy != null ? {
            allowCredentials = var.ingress.cors_policy.allow_credentials
            allowedHeaders   = var.ingress.cors_policy.allowed_headers
            allowedMethods   = var.ingress.cors_policy.allowed_methods
            allowedOrigins   = var.ingress.cors_policy.allowed_origins
            exposeHeaders    = var.ingress.cors_policy.expose_headers
            maxAge           = var.ingress.cors_policy.max_age
          } : null
          customDomains = var.ingress.custom_domain != null ? [
            {
              bindingType   = var.ingress.custom_domain.certificate_binding_type
              certificateId = var.ingress.custom_domain.certificate_id
              name          = var.ingress.custom_domain.name
            }
          ] : null
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
          traffic = var.ingress.traffic_weight == null ? [{
            label          = ""
            latestRevision = true
            revisionName   = ""
            weight         = 100
            }] : [
            for weight in var.ingress.traffic_weight : {
              label          = weight.label
              latestRevision = weight.latest_revision
              revisionName   = weight.revision_suffix
              weight         = weight.percentage
            }
          ]
        } : null
        maxInactiveRevisions = var.max_inactive_revisions
        registries = var.registries != null ? [
          for reg in var.registries : {
            identity          = reg.identity
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
        secrets = var.secrets != null ? [
          for s in var.secrets : {
            identity    = s.identity
            keyVaultUrl = s.key_vault_secret_id
            name        = s.name
            value       = s.value
          }
        ] : null
        service = var.service != null ? {
          type = var.service.type
        } : null
      }
      environmentId = var.container_app_environment_resource_id
      template = {
        containers = [
          for cont in var.template.containers : {
            args    = cont.args
            command = cont.command
            env = cont.env != null ? [
              for e in cont.env : {
                name      = e.name
                secretRef = e.secret_name
                value     = e.value
              }
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
          }
        ]
        initContainers = var.template.init_containers != null ? [
          for init_cont in var.template.init_containers : {
            args    = init_cont.args
            command = init_cont.command
            env = init_cont.env != null ? [
              for e in init_cont.env : {
                name      = e.name
                secretRef = e.secret_name
                value     = e.value
              }
            ] : null
            image = init_cont.image
            name  = init_cont.name
            resources = {
              cpu    = init_cont.cpu
              memory = init_cont.memory
            }
            volumeMounts = init_cont.volume_mounts != null ? [
              for vm in init_cont.volume_mounts : {
                mountPath  = vm.path
                subPath    = vm.sub_path
                volumeName = vm.name
              }
            ] : null
          }
        ] : null
        revisionSuffix = var.template.revision_suffix
        scale = {
          minReplicas = var.template.min_replicas
          maxReplicas = var.template.max_replicas
          # Add missing scale properties
          cooldownPeriod  = null # TODO add this as direct variable later
          pollingInterval = null # TODO add this as direct variable later
          rules           = length(local.scale_rules) > 0 ? local.scale_rules : null
        }
        serviceBinds = var.template.service_binds != null ? [
          for sb in var.template.service_binds : {
            name      = sb.name
            serviceId = sb.service_id
          }
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
        ] : null
      }
      workloadProfileName = var.workload_profile_name
    }
  }
  response_export_values = [
    "identity",
    "properties.configuration.ingress",
    "properties.customDomainVerificationId",
    "properties.outboundIpAddresses",
    "properties.revisionSuffix",
  ]
  schema_validation_enabled = true
  tags                      = var.tags

  dynamic "identity" {
    for_each = local.managed_identities.system_assigned_user_assigned

    content {
      type         = identity.value.type
      identity_ids = identity.value.user_assigned_resource_ids
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
    ]
  }
}

moved {
  from = azurerm_container_app.this
  to   = azapi_resource.container_app
}
