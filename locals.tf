data "azapi_client_config" "current" {}

data "azapi_resource" "rg" {
  name = var.resource_group_name
  type = "Microsoft.Resources/resourceGroups@2024-11-01"

  lifecycle {
    precondition {
      condition     = var.resource_group_id == null ? true : "/subscriptions/${data.azapi_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}" == var.resource_group_id
      error_message = "`var.resource_group_id` is not as expected: '/subscriptions/${data.azapi_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}'."
    }
  }
}

locals {
  container_probes = {
    for cont in var.template.containers : cont.name => concat(

      try(length(cont.liveness_probes) > 0, false) ? [
        for liveness_probe in try(cont.liveness_probes, []) : {
          failureThreshold              = liveness_probe.failure_count_threshold
          initialDelaySeconds           = liveness_probe.initial_delay
          periodSeconds                 = liveness_probe.interval_seconds
          terminationGracePeriodSeconds = liveness_probe.termination_grace_period_seconds
          timeoutSeconds                = liveness_probe.timeout
          type                          = "Liveness"
          httpGet = liveness_probe.transport == "HTTP" || liveness_probe.transport == "HTTPS" ? {
            host   = liveness_probe.host
            path   = liveness_probe.path
            port   = liveness_probe.port
            scheme = liveness_probe.transport
            httpHeaders = liveness_probe.header != null ? [
              for header in liveness_probe.header : {
                name  = header.name
                value = header.value
              }
            ] : null
          } : null
          tcpSocket = liveness_probe.transport == "TCP" ? {
            host = liveness_probe.host
            port = liveness_probe.port
          } : null
      }] : [],

      try(length(cont.readiness_probes) > 0, false) ? [
        for readiness_probe in try(cont.readiness_probes, []) : {
          failureThreshold    = readiness_probe.failure_count_threshold
          initialDelaySeconds = readiness_probe.initial_delay
          periodSeconds       = readiness_probe.interval_seconds
          successThreshold    = readiness_probe.success_count_threshold
          timeoutSeconds      = readiness_probe.timeout
          type                = "Readiness"
          httpGet = readiness_probe.transport == "HTTP" || readiness_probe.transport == "HTTPS" ? {
            host   = readiness_probe.host
            path   = readiness_probe.path
            port   = readiness_probe.port
            scheme = readiness_probe.transport
            httpHeaders = readiness_probe.header != null ? [
              for header in readiness_probe.header : {
                name  = header.name
                value = header.value
              }
            ] : null
          } : null
          tcpSocket = readiness_probe.transport == "TCP" ? {
            host = readiness_probe.host
            port = readiness_probe.port
          } : null
      }] : [],

      # TODO: The following block should be removed before the next major release
      try(length(cont.startup_probe) > 0, false) ? [
        for startup_probe in try(cont.startup_probe, []) : {
          failureThreshold              = startup_probe.failure_count_threshold
          initialDelaySeconds           = startup_probe.initial_delay
          periodSeconds                 = startup_probe.interval_seconds
          terminationGracePeriodSeconds = startup_probe.termination_grace_period_seconds
          timeoutSeconds                = startup_probe.timeout
          type                          = "Startup"
          httpGet = startup_probe.transport == "HTTP" || startup_probe.transport == "HTTPS" ? {
            host   = startup_probe.host
            path   = startup_probe.path
            port   = startup_probe.port
            scheme = startup_probe.transport
            httpHeaders = startup_probe.header != null ? [
              for header in startup_probe.header : {
                name  = header.name
                value = header.value
              }
            ] : null
          } : null
          tcpSocket = startup_probe.transport == "TCP" ? {
            host = startup_probe.host
            port = startup_probe.port
          } : null
      }] : [],

      try(length(cont.startup_probes) > 0, false) ? [
        for startup_probe in try(cont.startup_probes, []) : {
          failureThreshold              = startup_probe.failure_count_threshold
          initialDelaySeconds           = startup_probe.initial_delay
          periodSeconds                 = startup_probe.interval_seconds
          terminationGracePeriodSeconds = startup_probe.termination_grace_period_seconds
          timeoutSeconds                = startup_probe.timeout
          type                          = "Startup"
          httpGet = startup_probe.transport == "HTTP" || startup_probe.transport == "HTTPS" ? {
            host   = startup_probe.host
            path   = startup_probe.path
            port   = startup_probe.port
            scheme = startup_probe.transport
            httpHeaders = startup_probe.header != null ? [
              for header in startup_probe.header : {
                name  = header.name
                value = header.value
              }
            ] : null
          } : null
          tcpSocket = startup_probe.transport == "TCP" ? {
            host = startup_probe.host
            port = startup_probe.port
          } : null
      }] : [],
    )
  }
  main_location     = coalesce(var.location, data.azapi_resource.rg.location)
  resource_group_id = coalesce(var.resource_group_id, data.azapi_resource.rg.id)
  scale_rules = concat(
    var.template.azure_queue_scale_rules != null ? [
      for rule in var.template.azure_queue_scale_rules : {
        name = rule.name
        azureQueue = {
          accountName = rule.account_name
          queueName   = rule.queue_name
          queueLength = rule.queue_length
          identity    = rule.identity
          auth = rule.authentication != null ? [
            for auth in rule.authentication : {
              secretRef        = auth.secret_name
              triggerParameter = auth.trigger_parameter
            }
          ] : null
        }
        custom = null
        http   = null
        tcp    = null
      }
    ] : [],

    var.template.custom_scale_rules != null ? [
      for rule in var.template.custom_scale_rules : {
        name = rule.name
        custom = {
          type     = rule.custom_rule_type
          metadata = rule.metadata
          identity = rule.identity
          auth = rule.authentication != null ? [
            for auth in rule.authentication : {
              secretRef        = auth.secret_name
              triggerParameter = auth.trigger_parameter
            }
          ] : null
        }
        azureQueue = null
        http       = null
        tcp        = null
      }
    ] : [],

    var.template.http_scale_rules != null ? [
      for rule in var.template.http_scale_rules : {
        name = rule.name
        http = {
          metadata = rule.metadata != null ? rule.metadata : {
            concurrentRequests = rule.concurrent_requests
          }
          identity = rule.identity
          auth = rule.authentication != null ? [
            for auth in rule.authentication : {
              secretRef        = auth.secret_name
              triggerParameter = auth.trigger_parameter
            }
          ] : null
        }
        azureQueue = null
        custom     = null
        tcp        = null
      }
    ] : [],

    var.template.tcp_scale_rules != null ? [
      for rule in var.template.tcp_scale_rules : {
        name = rule.name
        tcp = {
          metadata = rule.metadata != null ? rule.metadata : {
            concurrentRequests = rule.concurrent_requests
          }
          identity = rule.identity
          auth = rule.authentication != null ? [
            for auth in rule.authentication : {
              secretRef        = auth.secret_name
              triggerParameter = auth.trigger_parameter
            }
          ] : null
        }
        azureQueue = null
        custom     = null
        http       = null
      }
    ] : []
  )
}
