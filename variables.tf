variable "container_app_environment_id" {
  type        = string
  description = "The ID of the Container App Environment to host this Container App."
  nullable    = false
}

variable "name" {
  type        = string
  description = "The name for this Container App."
  nullable    = false
}

variable "resource_group_name" {
  type        = string
  description = "(Required) The name of the resource group in which the Container App Environment is to be created. Changing this forces a new resource to be created."
  nullable    = false
}

variable "revision_mode" {
  type        = string
  description = "(Required) The revisions operational mode for the Container App. Possible values include `Single` and `Multiple`. In `Single` mode, a single revision is in operation at any given time. In `Multiple` mode, more than one revision can be active at a time and can be configured with load distribution via the `traffic_weight` block in the `ingress` configuration."
  nullable    = false
}

variable "template" {
  type = object({
    max_replicas    = optional(number)
    min_replicas    = optional(number)
    revision_suffix = optional(string)
    azure_queue_scale_rules = optional(list(object({
      name         = string
      queue_length = number
      queue_name   = string
      authentication = list(object({
        secret_name       = string
        trigger_parameter = string
      }))
    })))
    containers = list(object({
      args    = optional(list(string))
      command = optional(list(string))
      cpu     = number
      image   = string
      memory  = string
      name    = string
      env = optional(list(object({
        name        = string
        secret_name = optional(string)
        value       = optional(string)
      })))
      liveness_probes = optional(list(object({
        failure_count_threshold = optional(number)
        host                    = optional(string)
        initial_delay           = optional(number)
        interval_seconds        = optional(number)
        path                    = optional(string)
        port                    = number
        timeout                 = optional(number)
        transport               = string
        header = optional(list(object({
          name  = string
          value = string
        })))
      })))
      readiness_probes = optional(list(object({
        failure_count_threshold = optional(number)
        host                    = optional(string)
        interval_seconds        = optional(number)
        path                    = optional(string)
        port                    = number
        success_count_threshold = optional(number)
        timeout                 = optional(number)
        transport               = string
        header = optional(list(object({
          name  = string
          value = string
        })))
      })))
      startup_probe = optional(list(object({
        failure_count_threshold = optional(number)
        host                    = optional(string)
        interval_seconds        = optional(number)
        path                    = optional(string)
        port                    = number
        timeout                 = optional(number)
        transport               = string
        header = optional(list(object({
          name  = string
          value = string
        })))
      })))
      volume_mounts = optional(list(object({
        name = string
        path = string
      })))
    }))
    custom_scale_rules = optional(list(object({
      custom_rule_type = string
      metadata         = map(string)
      name             = string
      authentication = optional(list(object({
        secret_name       = string
        trigger_parameter = string
      })))
    })))
    http_scale_rules = optional(list(object({
      concurrent_requests = string
      name                = string
      authentication = optional(list(object({
        secret_name       = string
        trigger_parameter = optional(string)
      })))
    })))
    init_containers = optional(list(object({
      args    = optional(list(string))
      command = optional(list(string))
      cpu     = optional(number)
      image   = string
      memory  = optional(string)
      name    = string
      env = optional(list(object({
        name        = string
        secret_name = optional(string)
        value       = optional(string)
      })))
      volume_mounts = optional(list(object({
        name = string
        path = string
      })))
    })))
    tcp_scale_rules = optional(list(object({
      concurrent_requests = string
      name                = string
      authentication = optional(list(object({
        secret_name       = string
        trigger_parameter = optional(string)
      })))
    })))
    volumes = optional(list(object({
      name         = string
      storage_name = optional(string)
      storage_type = optional(string)
    })))
  })
  description = <<-EOT
 - `max_replicas` - (Optional) The maximum number of replicas for this container.
 - `min_replicas` - (Optional) The minimum number of replicas for this container.
 - `revision_suffix` - (Optional) The suffix for the revision. This value must be unique for the lifetime of the Resource. If omitted the service will use a hash function to create one.

 ---
 `azure_queue_scale_rule` block supports the following:
 - `name` - (Required) The name of the Scaling Rule
 - `queue_length` - (Required) The value of the length of the queue to trigger scaling actions.
 - `queue_name` - (Required) The name of the Azure Queue

 ---
 `authentication` block supports the following:
 - `secret_name` - (Required) The name of the Container App Secret to use for this Scale Rule Authentication.
 - `trigger_parameter` - (Required) The Trigger Parameter name to use the supply the value retrieved from the `secret_name`.

 ---
 `container` block supports the following:
 - `args` - (Optional) A list of extra arguments to pass to the container.
 - `command` - (Optional) A command to pass to the container to override the default. This is provided as a list of command line elements without spaces.
 - `cpu` - (Required) The amount of vCPU to allocate to the container. Possible values include `0.25`, `0.5`, `0.75`, `1.0`, `1.25`, `1.5`, `1.75`, and `2.0`. When there's a workload profile specified, there's no such constraint.
 - `image` - (Required) The image to use to create the container.
 - `memory` - (Required) The amount of memory to allocate to the container. Possible values are `0.5Gi`, `1Gi`, `1.5Gi`, `2Gi`, `2.5Gi`, `3Gi`, `3.5Gi` and `4Gi`. When there's a workload profile specified, there's no such constraint.
 - `name` - (Required) The name of the container

 ---
 `env` block supports the following:
 - `name` - (Required) The name of the environment variable for the container.
 - `secret_name` - (Optional) The name of the secret that contains the value for this environment variable.
 - `value` - (Optional) The value for this environment variable.

 ---
 `liveness_probe` block supports the following:
 - `failure_count_threshold` - (Optional) The number of consecutive failures required to consider this probe as failed. Possible values are between `1` and `10`. Defaults to `3`.
 - `host` - (Optional) The probe hostname. Defaults to the pod IP address. Setting a value for `Host` in `headers` can be used to override this for `HTTP` and `HTTPS` type probes.
 - `initial_delay` - (Optional) The time in seconds to wait after the container has started before the probe is started.
 - `interval_seconds` - (Optional) How often, in seconds, the probe should run. Possible values are in the range `1`
 - `path` - (Optional) The URI to use with the `host` for http type probes. Not valid for `TCP` type probes. Defaults to `/`.
 - `port` - (Required) The port number on which to connect. Possible values are between `1` and `65535`.
 - `timeout` - (Optional) Time in seconds after which the probe times out. Possible values are in the range `1`
 - `transport` - (Required) Type of probe. Possible values are `TCP`, `HTTP`, and `HTTPS`.

 ---
 `header` block supports the following:
 - `name` - (Required) The HTTP Header Name.
 - `value` - (Required) The HTTP Header value.

 ---
 `readiness_probe` block supports the following:
 - `failure_count_threshold` - (Optional) The number of consecutive failures required to consider this probe as failed. Possible values are between `1` and `10`. Defaults to `3`.
 - `host` - (Optional) The probe hostname. Defaults to the pod IP address. Setting a value for `Host` in `headers` can be used to override this for `HTTP` and `HTTPS` type probes.
 - `interval_seconds` - (Optional) How often, in seconds, the probe should run. Possible values are between `1` and `240`. Defaults to `10`
 - `path` - (Optional) The URI to use for http type probes. Not valid for `TCP` type probes. Defaults to `/`.
 - `port` - (Required) The port number on which to connect. Possible values are between `1` and `65535`.
 - `success_count_threshold` - (Optional) The number of consecutive successful responses required to consider this probe as successful. Possible values are between `1` and `10`. Defaults to `3`.
 - `timeout` - (Optional) Time in seconds after which the probe times out. Possible values are in the range `1`
 - `transport` - (Required) Type of probe. Possible values are `TCP`, `HTTP`, and `HTTPS`.

 ---
 `header` block supports the following:
 - `name` - (Required) The HTTP Header Name.
 - `value` - (Required) The HTTP Header value.

 ---
 `startup_probe` block supports the following:
 - `failure_count_threshold` - (Optional) The number of consecutive failures required to consider this probe as failed. Possible values are between `1` and `10`. Defaults to `3`.
 - `host` - (Optional) The value for the host header which should be sent with this probe. If unspecified, the IP Address of the Pod is used as the host header. Setting a value for `Host` in `headers` can be used to override this for `HTTP` and `HTTPS` type probes.
 - `interval_seconds` - (Optional) How often, in seconds, the probe should run. Possible values are between `1` and `240`. Defaults to `10`
 - `path` - (Optional) The URI to use with the `host` for http type probes. Not valid for `TCP` type probes. Defaults to `/`.
 - `port` - (Required) The port number on which to connect. Possible values are between `1` and `65535`.
 - `timeout` - (Optional) Time in seconds after which the probe times out. Possible values are in the range `1`
 - `transport` - (Required) Type of probe. Possible values are `TCP`, `HTTP`, and `HTTPS`.

 ---
 `header` block supports the following:
 - `name` - (Required) The HTTP Header Name.
 - `value` - (Required) The HTTP Header value.

 ---
 `volume_mounts` block supports the following:
 - `name` - (Required) The name of the Volume to be mounted in the container.
 - `path` - (Required) The path in the container at which to mount this volume.

 ---
 `custom_scale_rule` block supports the following:
 - `custom_rule_type` - (Required) The Custom rule type. Possible values include: `activemq`, `artemis-queue`, `kafka`, `pulsar`, `aws-cloudwatch`, `aws-dynamodb`, `aws-dynamodb-streams`, `aws-kinesis-stream`, `aws-sqs-queue`, `azure-app-insights`, `azure-blob`, `azure-data-explorer`, `azure-eventhub`, `azure-log-analytics`, `azure-monitor`, `azure-pipelines`, `azure-servicebus`, `azure-queue`, `cassandra`, `cpu`, `cron`, `datadog`, `elasticsearch`, `external`, `external-push`, `gcp-stackdriver`, `gcp-storage`, `gcp-pubsub`, `graphite`, `http`, `huawei-cloudeye`, `ibmmq`, `influxdb`, `kubernetes-workload`, `liiklus`, `memory`, `metrics-api`, `mongodb`, `mssql`, `mysql`, `nats-jetstream`, `stan`, `tcp`, `new-relic`, `openstack-metric`, `openstack-swift`, `postgresql`, `predictkube`, `prometheus`, `rabbitmq`, `redis`, `redis-cluster`, `redis-sentinel`, `redis-streams`, `redis-cluster-streams`, `redis-sentinel-streams`, `selenium-grid`,`solace-event-queue`, and `github-runner`.
 - `metadata` - (Required)
 - `name` - (Required) The name of the Scaling Rule

 ---
 `authentication` block supports the following:
 - `secret_name` - (Required) The name of the Container App Secret to use for this Scale Rule Authentication.
 - `trigger_parameter` - (Required) The Trigger Parameter name to use the supply the value retrieved from the `secret_name`.

 ---
 `http_scale_rule` block supports the following:
 - `concurrent_requests` - (Required)
 - `name` - (Required) The name of the Scaling Rule

 ---
 `authentication` block supports the following:
 - `secret_name` - (Required) The name of the Container App Secret to use for this Scale Rule Authentication.
 - `trigger_parameter` - (Required) The Trigger Parameter name to use the supply the value retrieved from the `secret_name`.

 ---
 `init_container` block supports the following:
 - `args` - (Optional) A list of extra arguments to pass to the container.
 - `command` - (Optional) A command to pass to the container to override the default. This is provided as a list of command line elements without spaces.
 - `cpu` - (Optional) The amount of vCPU to allocate to the container. Possible values include `0.25`, `0.5`, `0.75`, `1.0`, `1.25`, `1.5`, `1.75`, and `2.0`. When there's a workload profile specified, there's no such constraint.
 - `image` - (Required) The image to use to create the container.
 - `memory` - (Optional) The amount of memory to allocate to the container. Possible values are `0.5Gi`, `1Gi`, `1.5Gi`, `2Gi`, `2.5Gi`, `3Gi`, `3.5Gi` and `4Gi`. When there's a workload profile specified, there's no such constraint.
 - `name` - (Required) The name of the container

 ---
 `env` block supports the following:
 - `name` - (Required) The name of the environment variable for the container.
 - `secret_name` - (Optional) The name of the secret that contains the value for this environment variable.
 - `value` - (Optional) The value for this environment variable.

 ---
 `volume_mounts` block supports the following:
 - `name` - (Required) The name of the Volume to be mounted in the container.
 - `path` - (Required) The path in the container at which to mount this volume.

 ---
 `tcp_scale_rule` block supports the following:
 - `concurrent_requests` - (Required)
 - `name` - (Required) The name of the Scaling Rule

 ---
 `authentication` block supports the following:
 - `secret_name` - (Required) The name of the Container App Secret to use for this Scale Rule Authentication.
 - `trigger_parameter` - (Required) The Trigger Parameter name to use the supply the value retrieved from the `secret_name`.

 ---
 `volume` block supports the following:
 - `name` - (Required) The name of the volume.
 - `storage_name` - (Optional) The name of the `AzureFile` storage.
 - `storage_type` - (Optional) The type of storage volume. Possible values are `AzureFile`, `EmptyDir` and `Secret`. Defaults to `EmptyDir`.
EOT
  nullable    = false
}

variable "container_app_timeouts" {
  type = object({
    create = optional(string)
    delete = optional(string)
    read   = optional(string)
    update = optional(string)
  })
  default     = null
  description = <<-EOT
 - `create` - (Defaults to 30 minutes) Used when creating the Container App.
 - `delete` - (Defaults to 30 minutes) Used when deleting the Container App.
 - `read` - (Defaults to 5 minutes) Used when retrieving the Container App.
 - `update` - (Defaults to 30 minutes) Used when updating the Container App.
EOT
}

variable "custom_domains" {
  type = map(object({
    certificate_binding_type                 = optional(string)
    container_app_environment_certificate_id = optional(string)
    name                                     = string
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
    }))
  }))
  default     = {}
  description = <<-EOT
 - `certificate_binding_type` - (Optional) The Certificate Binding type. Possible values include `Disabled` and `SniEnabled`.  Required with `container_app_environment_certificate_id`. Changing this forces a new resource to be created.
 - `container_app_environment_certificate_id` - (Optional) The ID of the Container App Environment Certificate to use. Changing this forces a new resource to be created.
 - `name` - (Required) The fully qualified name of the Custom Domain. Must be the CN or a named SAN in the certificate specified by the `container_app_environment_certificate_id`. Changing this forces a new resource to be created.

 ---
 `timeouts` block supports the following:
 - `create` - (Defaults to 30 minutes) Used when creating the Container App.
 - `delete` - (Defaults to 30 minutes) Used when deleting the Container App.
 - `read` - (Defaults to 5 minutes) Used when retrieving the Container App.
EOT
  nullable    = false
}

variable "dapr" {
  type = object({
    app_id       = string
    app_port     = optional(number)
    app_protocol = optional(string)
  })
  default     = null
  description = <<-EOT
 - `app_id` - (Required) The Dapr Application Identifier.
 - `app_port` - (Optional) The port which the application is listening on. This is the same as the `ingress` port.
 - `app_protocol` - (Optional) The protocol for the app. Possible values include `http` and `grpc`. Defaults to `http`.
EOT
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
}

variable "ingress" {
  type = object({
    allow_insecure_connections = optional(bool)
    exposed_port               = optional(number)
    external_enabled           = optional(bool)
    target_port                = number
    transport                  = optional(string)
    custom_domain = optional(object({
      certificate_binding_type = optional(string)
      certificate_id           = string
      name                     = string
    }))
    ip_security_restriction = optional(list(object({
      action           = string
      description      = optional(string)
      ip_address_range = string
      name             = string
    })))
    traffic_weight = list(object({
      label           = optional(string)
      latest_revision = optional(bool)
      percentage      = number
      revision_suffix = optional(string)
    }))
  })
  default     = null
  description = <<-EOT
 - `allow_insecure_connections` - (Optional) Should this ingress allow insecure connections?
 - `exposed_port` - (Optional) The exposed port on the container for the Ingress traffic.
 - `external_enabled` - (Optional) Are connections to this Ingress from outside the Container App Environment enabled? Defaults to `false`.
 - `target_port` - (Required) The target port on the container for the Ingress traffic.
 - `transport` - (Optional) The transport method for the Ingress. Possible values are `auto`, `http`, `http2` and `tcp`. Defaults to `auto`.

 ---
 `custom_domain` block supports the following:
 - `certificate_binding_type` - (Optional) The Binding type. Possible values include `Disabled` and `SniEnabled`. Defaults to `Disabled`.
 - `certificate_id` - (Required) The ID of the Container App Environment Certificate.
 - `name` - (Required) The hostname of the Certificate. Must be the CN or a named SAN in the certificate.

 ---
 `ip_security_restriction` block supports the following:
 - `action` - (Required) The IP-filter action. `Allow` or `Deny`.
 - `description` - (Optional) Describe the IP restriction rule that is being sent to the container-app.
 - `ip_address_range` - (Required) The incoming IP address or range of IP addresses (in CIDR notation).
 - `name` - (Required) Name for the IP restriction rule.

 ---
 `traffic_weight` block supports the following:
 - `label` - (Optional) The label to apply to the revision as a name prefix for routing traffic.
 - `latest_revision` - (Optional) This traffic Weight applies to the latest stable Container Revision. At most only one `traffic_weight` block can have the `latest_revision` set to `true`.
 - `percentage` - (Required) The percentage of traffic which should be sent this revision.
 - `revision_suffix` - (Optional) The suffix string to which this `traffic_weight` applies.
EOT
}

variable "lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  default     = null
  description = <<DESCRIPTION
  Controls the Resource Lock configuration for this resource. The following properties can be specified:

  - `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
  - `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.
  DESCRIPTION

  validation {
    condition     = var.lock != null ? contains(["CanNotDelete", "ReadOnly"], var.lock.kind) : true
    error_message = "Lock kind must be either `\"CanNotDelete\"` or `\"ReadOnly\"`."
  }
}

variable "managed_identities" {
  type = object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
  default     = {}
  description = <<DESCRIPTION
  Controls the Managed Identity configuration on this resource. The following properties can be specified:

  - `system_assigned` - (Optional) Specifies if the System Assigned Managed Identity should be enabled.
  - `user_assigned_resource_ids` - (Optional) Specifies a list of User Assigned Managed Identity resource IDs to be assigned to this resource.
  DESCRIPTION
  nullable    = false
}

variable "registry" {
  type = list(object({
    identity             = optional(string)
    password_secret_name = optional(string)
    server               = string
    username             = optional(string)
  }))
  default     = null
  description = <<-EOT
 - `identity` - (Optional) Resource ID for the User Assigned Managed identity to use when pulling from the Container Registry.
 - `password_secret_name` - (Optional) The name of the Secret Reference containing the password value for this user on the Container Registry, `username` must also be supplied.
 - `server` - (Required) The hostname for the Container Registry.
 - `username` - (Optional) The username to use for this Container Registry, `password_secret_name` must also be supplied..
EOT
}

variable "role_assignments" {
  type = map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
  A map of role assignments to create on the <RESOURCE>. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

  - `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
  - `principal_id` - The ID of the principal to assign the role to.
  - `description` - (Optional) The description of the role assignment.
  - `skip_service_principal_aad_check` - (Optional) If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
  - `condition` - (Optional) The condition which will be used to scope the role assignment.
  - `condition_version` - (Optional) The version of the condition syntax. Leave as `null` if you are not using a condition, if you are then valid values are '2.0'.
  - `delegated_managed_identity_resource_id` - (Optional) The delegated Azure Resource Id which contains a Managed Identity. Changing this forces a new resource to be created. This field is only used in cross-tenant scenario.
  - `principal_type` - (Optional) The type of the `principal_id`. Possible values are `User`, `Group` and `ServicePrincipal`. It is necessary to explicitly set this attribute when creating role assignments if the principal creating the assignment is constrained by ABAC rules that filters on the PrincipalType attribute.

  > Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.
  DESCRIPTION
  nullable    = false
}

variable "secrets" {
  type = map(object({
    identity            = optional(string)
    key_vault_secret_id = optional(string)
    name                = string
    value               = optional(string)
  }))
  default     = {}
  nullable = false
  description = <<-EOT
 - `identity` - (Optional) The identity to use for accessing the Key Vault secret reference. This can either be the Resource ID of a User Assigned Identity, or `System` for the System Assigned Identity.
 - `key_vault_secret_id` - (Optional) The ID of a Key Vault secret. This can be a versioned or version-less ID.
 - `name` - (Required) The secret name.
 - `value` - (Optional) The value for this secret.
EOT
  sensitive   = true
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) A mapping of tags to assign to the Container App."
}

variable "workload_profile_name" {
  type        = string
  default     = null
  description = "(Optional) The name of the Workload Profile in the Container App Environment to place this Container App."
}
