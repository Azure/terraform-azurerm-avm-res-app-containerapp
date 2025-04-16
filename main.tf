resource "azurerm_container_app" "this" {
  container_app_environment_id = var.container_app_environment_resource_id
  name                         = var.name
  resource_group_name          = var.resource_group_name
  revision_mode                = var.revision_mode
  tags                         = var.tags
  workload_profile_name        = var.workload_profile_name

  dynamic "template" {
    for_each = [var.template]

    content {
      max_replicas    = template.value.max_replicas
      min_replicas    = template.value.min_replicas
      revision_suffix = template.value.revision_suffix

      dynamic "container" {
        for_each = template.value.containers

        content {
          cpu     = container.value.cpu
          image   = container.value.image
          memory  = container.value.memory
          name    = container.value.name
          args    = container.value.args
          command = container.value.command

          dynamic "env" {
            for_each = container.value.env == null ? [] : container.value.env

            content {
              name        = env.value.name
              secret_name = env.value.secret_name
              value       = env.value.value
            }
          }
          dynamic "liveness_probe" {
            for_each = container.value.liveness_probes == null ? [] : container.value.liveness_probes

            content {
              port                    = liveness_probe.value.port
              transport               = liveness_probe.value.transport
              failure_count_threshold = liveness_probe.value.failure_count_threshold
              host                    = liveness_probe.value.host
              initial_delay           = liveness_probe.value.initial_delay
              interval_seconds        = liveness_probe.value.interval_seconds
              path                    = liveness_probe.value.path
              timeout                 = liveness_probe.value.timeout

              dynamic "header" {
                for_each = liveness_probe.value.header == null ? [] : liveness_probe.value.header

                content {
                  name  = header.value.name
                  value = header.value.value
                }
              }
            }
          }
          dynamic "readiness_probe" {
            for_each = container.value.readiness_probes == null ? [] : container.value.readiness_probes

            content {
              port                    = readiness_probe.value.port
              transport               = readiness_probe.value.transport
              failure_count_threshold = readiness_probe.value.failure_count_threshold
              host                    = readiness_probe.value.host
              initial_delay           = readiness_probe.value.initial_delay
              interval_seconds        = readiness_probe.value.interval_seconds
              path                    = readiness_probe.value.path
              success_count_threshold = readiness_probe.value.success_count_threshold
              timeout                 = readiness_probe.value.timeout

              dynamic "header" {
                for_each = readiness_probe.value.header == null ? [] : readiness_probe.value.header

                content {
                  name  = header.value.name
                  value = header.value.value
                }
              }
            }
          }
          dynamic "startup_probe" {
            for_each = container.value.startup_probe == null ? [] : container.value.startup_probe

            content {
              port                    = startup_probe.value.port
              transport               = startup_probe.value.transport
              failure_count_threshold = startup_probe.value.failure_count_threshold
              host                    = startup_probe.value.host
              interval_seconds        = startup_probe.value.interval_seconds
              path                    = startup_probe.value.path
              timeout                 = startup_probe.value.timeout

              dynamic "header" {
                for_each = startup_probe.value.header == null ? [] : startup_probe.value.header

                content {
                  name  = header.value.name
                  value = header.value.value
                }
              }
            }
          }
          dynamic "volume_mounts" {
            for_each = container.value.volume_mounts == null ? [] : container.value.volume_mounts

            content {
              name = volume_mounts.value.name
              path = volume_mounts.value.path
            }
          }
        }
      }
      dynamic "azure_queue_scale_rule" {
        for_each = template.value.azure_queue_scale_rules == null ? [] : template.value.azure_queue_scale_rules

        content {
          name         = azure_queue_scale_rule.value.name
          queue_length = azure_queue_scale_rule.value.queue_length
          queue_name   = azure_queue_scale_rule.value.queue_name

          dynamic "authentication" {
            for_each = azure_queue_scale_rule.value.authentication

            content {
              secret_name       = authentication.value.secret_name
              trigger_parameter = authentication.value.trigger_parameter
            }
          }
        }
      }
      dynamic "custom_scale_rule" {
        for_each = template.value.custom_scale_rules == null ? [] : template.value.custom_scale_rules

        content {
          custom_rule_type = custom_scale_rule.value.custom_rule_type
          metadata         = custom_scale_rule.value.metadata
          name             = custom_scale_rule.value.name

          dynamic "authentication" {
            for_each = custom_scale_rule.value.authentication == null ? [] : custom_scale_rule.value.authentication

            content {
              secret_name       = authentication.value.secret_name
              trigger_parameter = authentication.value.trigger_parameter
            }
          }
        }
      }
      dynamic "http_scale_rule" {
        for_each = template.value.http_scale_rules == null ? [] : template.value.http_scale_rules

        content {
          concurrent_requests = http_scale_rule.value.concurrent_requests
          name                = http_scale_rule.value.name

          dynamic "authentication" {
            for_each = http_scale_rule.value.authentication == null ? [] : http_scale_rule.value.authentication

            content {
              secret_name       = authentication.value.secret_name
              trigger_parameter = authentication.value.trigger_parameter
            }
          }
        }
      }
      dynamic "init_container" {
        for_each = template.value.init_containers == null ? [] : template.value.init_containers

        content {
          image   = init_container.value.image
          name    = init_container.value.name
          args    = init_container.value.args
          command = init_container.value.command
          cpu     = init_container.value.cpu
          memory  = init_container.value.memory

          dynamic "env" {
            for_each = init_container.value.env == null ? [] : init_container.value.env

            content {
              name        = env.value.name
              secret_name = env.value.secret_name
              value       = env.value.value
            }
          }
          dynamic "volume_mounts" {
            for_each = init_container.value.volume_mounts == null ? [] : init_container.value.volume_mounts

            content {
              name = volume_mounts.value.name
              path = volume_mounts.value.path
            }
          }
        }
      }
      dynamic "tcp_scale_rule" {
        for_each = template.value.tcp_scale_rules == null ? [] : template.value.tcp_scale_rules

        content {
          concurrent_requests = tcp_scale_rule.value.concurrent_requests
          name                = tcp_scale_rule.value.name

          dynamic "authentication" {
            for_each = tcp_scale_rule.value.authentication == null ? [] : tcp_scale_rule.value.authentication

            content {
              secret_name       = authentication.value.secret_name
              trigger_parameter = authentication.value.trigger_parameter
            }
          }
        }
      }
      dynamic "volume" {
        for_each = template.value.volumes == null ? [] : template.value.volumes

        content {
          name         = volume.value.name
          storage_name = volume.value.storage_name
          storage_type = volume.value.storage_type
        }
      }
    }
  }
  dynamic "dapr" {
    for_each = var.dapr == null ? [] : [var.dapr]

    content {
      app_id       = dapr.value.app_id
      app_port     = dapr.value.app_port
      app_protocol = dapr.value.app_protocol
    }
  }
  ## Resources supporting both SystemAssigned and UserAssigned
  dynamic "identity" {
    for_each = local.managed_identities.system_assigned_user_assigned

    content {
      type         = identity.value.type
      identity_ids = identity.value.user_assigned_resource_ids
    }
  }
  dynamic "ingress" {
    for_each = var.ingress == null ? [] : [var.ingress]

    content {
      target_port                = ingress.value.target_port
      allow_insecure_connections = ingress.value.allow_insecure_connections
      client_certificate_mode    = ingress.value.client_certificate_mode
      exposed_port               = ingress.value.exposed_port
      external_enabled           = ingress.value.external_enabled
      transport                  = ingress.value.transport

      dynamic "traffic_weight" {
        for_each = ingress.value.traffic_weight

        content {
          percentage      = traffic_weight.value.percentage
          label           = traffic_weight.value.label
          latest_revision = traffic_weight.value.latest_revision
          revision_suffix = traffic_weight.value.revision_suffix
        }
      }
      dynamic "ip_security_restriction" {
        for_each = ingress.value.ip_security_restriction == null ? [] : ingress.value.ip_security_restriction

        content {
          action           = ip_security_restriction.value.action
          ip_address_range = ip_security_restriction.value.ip_address_range
          name             = ip_security_restriction.value.name
          description      = ip_security_restriction.value.description
        }
      }
    }
  }
  dynamic "registry" {
    for_each = var.registries == null ? [] : var.registries

    content {
      server               = registry.value.server
      identity             = registry.value.identity
      password_secret_name = registry.value.password_secret_name
      username             = registry.value.username
    }
  }
  dynamic "secret" {
    for_each = nonsensitive(var.secrets) == null ? {} : nonsensitive(var.secrets)

    content {
      name                = secret.value.name
      identity            = secret.value.identity
      key_vault_secret_id = secret.value.key_vault_secret_id
      value               = sensitive(secret.value.value)
    }
  }
  dynamic "timeouts" {
    for_each = var.container_app_timeouts == null ? [] : [var.container_app_timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

resource "azurerm_container_app_custom_domain" "this" {
  for_each = var.custom_domains

  container_app_id                         = azurerm_container_app.this.id
  name                                     = each.value.name
  certificate_binding_type                 = each.value.certificate_binding_type
  container_app_environment_certificate_id = each.value.container_app_environment_certificate_id

  dynamic "timeouts" {
    for_each = each.value.timeouts == null ? [] : [each.value.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
    }
  }
}

# Example resource implementation
resource "azurerm_management_lock" "this" {
  count = var.lock != null ? 1 : 0

  lock_level = var.lock.kind
  name       = coalesce(var.lock.name, "lock-${var.lock.kind}")
  scope      = azurerm_container_app.this.id
  notes      = var.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."
}