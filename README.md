<!-- BEGIN_TF_DOCS -->
# terraform-azurerm-avm-res-app-containerapp

This is a template repo for Terraform Azure Verified Container App Modules.

This module *DOES NOT* contain other Container App related resource, including `azurerm_container_app_environment`.

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.9, < 2.0)

- <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) (~> 2.5)

- <a name="requirement_modtm"></a> [modtm](#requirement\_modtm) (~> 0.3)

- <a name="requirement_random"></a> [random](#requirement\_random) (~> 3.0)

## Resources

The following resources are used by this module:

- [azapi_resource.auth_config](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) (resource)
- [azapi_resource.container_app](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) (resource)
- [azapi_resource.lock](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) (resource)
- [azapi_resource.role_assignments](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) (resource)
- [modtm_telemetry.telemetry](https://registry.terraform.io/providers/Azure/modtm/latest/docs/resources/telemetry) (resource)
- [random_uuid.telemetry](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) (resource)
- [azapi_client_config.current](https://registry.terraform.io/providers/Azure/azapi/latest/docs/data-sources/client_config) (data source)
- [azapi_client_config.telemetry](https://registry.terraform.io/providers/Azure/azapi/latest/docs/data-sources/client_config) (data source)
- [azapi_resource.rg](https://registry.terraform.io/providers/Azure/azapi/latest/docs/data-sources/resource) (data source)
- [modtm_module_source.telemetry](https://registry.terraform.io/providers/Azure/modtm/latest/docs/data-sources/module_source) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_container_app_environment_resource_id"></a> [container\_app\_environment\_resource\_id](#input\_container\_app\_environment\_resource\_id)

Description: The ID of the Container App Environment to host this Container App.

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: The name of the Container App.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: (Required) The name of the resource group in which the Container App Environment is to be created. Changing this forces a new resource to be created.

Type: `string`

### <a name="input_template"></a> [template](#input\_template)

Description:  - `cooldown_period` - (Optional) The cooldown period in seconds after a scaling action before another scaling action can be triggered. Defaults to `300`.
 - `max_replicas` - (Optional) The maximum number of replicas for this container.
 - `min_replicas` - (Optional) The minimum number of replicas for this container.
 - `polling_interval` - (Optional) The interval in seconds at which the scaling rules are evaluated. Defaults to `30`.
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
 `containers` block supports the following:
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
 `liveness_probes` block supports the following:
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
 `readiness_probes` block supports the following:
 - `failure_count_threshold` - (Optional) The number of consecutive failures required to consider this probe as failed. Possible values are between `1` and `10`. Defaults to `3`.
 - `host` - (Optional) The probe hostname. Defaults to the pod IP address. Setting a value for `Host` in `headers` can be used to override this for `HTTP` and `HTTPS` type probes.
 - `initial_delay` - (Optional) The number of seconds elapsed after the container has started before the probe is initiated. Possible values are between `0` and `60`. Defaults to `0` seconds.
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
 `startup_probe` block has been deprecated and would be removed in `v1`, please use `startup_probes` instead!. `startup_probe` block supports the following:
 - `failure_count_threshold` - (Optional) The number of consecutive failures required to consider this probe as failed. Possible values are between `1` and `10`. Defaults to `3`.
 - `host` - (Optional) The value for the host header which should be sent with this probe. If unspecified, the IP Address of the Pod is used as the host header. Setting a value for `Host` in `headers` can be used to override this for `HTTP` and `HTTPS` type probes.
 - `initial_delay` - (Optional) The number of seconds elapsed after the container has started before the probe is initiated. Possible values are between `0` and `60`. Defaults to `0` seconds.
 - `interval_seconds` - (Optional) How often, in seconds, the probe should run. Possible values are between `1` and `240`. Defaults to `10`
 - `path` - (Optional) The URI to use with the `host` for http type probes. Not valid for `TCP` type probes. Defaults to `/`.
 - `port` - (Required) The port number on which to connect. Possible values are between `1` and `65535`.
 - `timeout` - (Optional) Time in seconds after which the probe times out. Possible values are in the range `1`
 - `transport` - (Required) Type of probe. Possible values are `TCP`, `HTTP`, and `HTTPS`.

 ---
 `startup_probes` block supports the following:
 - `failure_count_threshold` - (Optional) The number of consecutive failures required to consider this probe as failed. Possible values are between `1` and `10`. Defaults to `3`.
 - `host` - (Optional) The value for the host header which should be sent with this probe. If unspecified, the IP Address of the Pod is used as the host header. Setting a value for `Host` in `headers` can be used to override this for `HTTP` and `HTTPS` type probes.
 - `initial_delay` - (Optional) The number of seconds elapsed after the container has started before the probe is initiated. Possible values are between `0` and `60`. Defaults to `0` seconds.
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

Type:

```hcl
object({
    cooldown_period = optional(number, 300)
    max_replicas    = optional(number, 10)
    #TODO:Set `min_replicas` default value to `0` in `v1.0.0`
    min_replicas     = optional(number)
    polling_interval = optional(number, 30)
    revision_suffix  = optional(string)
    #TODO:Set `termination_grace_period_seconds` default value to `0` in `v1.0.0`
    termination_grace_period_seconds = optional(number)

    azure_queue_scale_rules = optional(list(object({
      name         = string
      queue_length = number
      queue_name   = string
      account_name = optional(string)
      identity     = optional(string)
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
        failure_count_threshold          = optional(number, 3)
        host                             = optional(string)
        initial_delay                    = optional(number, 1)
        interval_seconds                 = optional(number, 10)
        path                             = optional(string)
        port                             = number
        termination_grace_period_seconds = optional(number)
        timeout                          = optional(number, 1)
        transport                        = string
        header = optional(list(object({
          name  = string
          value = string
        })))
      })))
      readiness_probes = optional(list(object({
        failure_count_threshold = optional(number, 3)
        host                    = optional(string)
        initial_delay           = optional(number, 0)
        interval_seconds        = optional(number, 10)
        path                    = optional(string)
        port                    = number
        success_count_threshold = optional(number, 3)
        timeout                 = optional(number, 1)
        transport               = string
        header = optional(list(object({
          name  = string
          value = string
        })))
      })))
      #TODO:Remove startup_probe in v1.0.0
      startup_probe = optional(list(object({
        failure_count_threshold          = optional(number, 3)
        host                             = optional(string)
        initial_delay                    = optional(number, 0)
        interval_seconds                 = optional(number, 10)
        path                             = optional(string)
        port                             = number
        termination_grace_period_seconds = optional(number)
        timeout                          = optional(number, 1)
        transport                        = string
        header = optional(list(object({
          name  = string
          value = string
        })))
      })))
      startup_probes = optional(list(object({
        failure_count_threshold          = optional(number, 3)
        host                             = optional(string)
        initial_delay                    = optional(number, 0)
        interval_seconds                 = optional(number, 10)
        path                             = optional(string)
        port                             = number
        termination_grace_period_seconds = optional(number)
        timeout                          = optional(number, 1)
        transport                        = string
        header = optional(list(object({
          name  = string
          value = string
        })))
      })))
      volume_mounts = optional(list(object({
        name     = string
        path     = string
        sub_path = optional(string)
      })))
    }))
    custom_scale_rules = optional(list(object({
      custom_rule_type = string
      metadata         = map(string)
      name             = string
      identity         = optional(string)
      authentication = optional(list(object({
        secret_name       = string
        trigger_parameter = string
      })))
    })))
    http_scale_rules = optional(list(object({
      concurrent_requests = string
      name                = string
      identity            = optional(string)
      metadata            = optional(map(string))
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
        name     = string
        path     = string
        sub_path = optional(string)
      })))
    })))

    service_binds = optional(list(object({
      name       = string
      service_id = string
    })))

    tcp_scale_rules = optional(list(object({
      concurrent_requests = string
      name                = string
      identity            = optional(string)
      metadata            = optional(map(string))
      authentication = optional(list(object({
        secret_name       = string
        trigger_parameter = optional(string)
      })))
    })))
    volumes = optional(list(object({
      mount_options = optional(string)
      name          = string
      secrets = optional(list(object({
        path        = string
        secret_name = string
      })))
      storage_name = optional(string)
      storage_type = optional(string, "EmptyDir")
    })))
  })
```

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_auth_configs"></a> [auth\_configs](#input\_auth\_configs)

Description: - `name` - (Required) Name of the Container App AuthConfig.

---
`platform` The configuration settings of the platform of ContainerApp Service Authentication/Authorization. The `platform` block supports the following:
  - `enabled` - (Optional) `true` if the Authentication / Authorization feature is enabled for the current app; otherwise, `false`.
  - `runtime_version` - (Optional) The RuntimeVersion of the Authentication / Authorization feature in use for the current app. The setting in this value can control the behavior of certain features in the Authentication / Authorization module.

---
`global_validation` The configuration settings that determines the validation flow of users using Service Authentication/Authorization. The `global_validation` block supports the following:
  - `unauthenticated_client_action` - (Optional) The action to take when an unauthenticated client attempts to access the app. Possible values include `AllowAnonymous`, `RedirectToLoginPage`, `Return401`  and `Return403`.
  - `redirect_to_provider` - (Optional) The default authentication provider to use when multiple providers are configured. This setting is only needed if multiple providers are configured and the unauthenticated client action is set to "RedirectToLoginPage".
  - `exclude_paths` - (Optional) The paths for which unauthenticated flow would not be redirected to the login page.

---
`identity_providers` The configuration settings of each of the identity providers used to configure ContainerApp Service Authentication/Authorization. The `identity_providers` block supports the following:
  - `azure_active_directory` - (Optional) The configuration settings of the Azure Active directory provider. The `azure_active_directory` block supports the following:
    - `enabled` - (Optional) `false` if the Azure Active Directory provider should not be enabled despite the set registration; otherwise, `true`.
    - `is_auto_provisioned` - (Optional) Gets a value indicating whether the Azure AD configuration was auto-provisioned using 1st party tooling. This is an internal flag primarily intended to support the Azure Management Portal. Users should not read or write to this property.
    - `registration` - (Optional) The registration settings for the Azure Active Directory provider. The `registration` block supports the following:
      - `open_id_issuer` - (Optional) The OpenID Connect Issuer URI that represents the entity which issues access tokens for this application. When using Azure Active Directory, this value is the URI of the directory tenant, e.g. https://login.microsoftonline.com/v2.0/{tenant-guid}/. This URI is a case-sensitive identifier for the token issuer. More information on OpenID Connect Discovery: http://openid.net/specs/openid-connect-discovery-1_0.html
      - `client_id` - (Optional) The Client ID of this relying party application, known as the client\_id. This setting is required for enabling OpenID Connection authentication with Azure Active Directory or other 3rd party OpenID Connect providers. More information on OpenID Connect: http://openid.net/specs/openid-connect-core-1_0.html
      - `client_secret_setting_name` - (Optional) The app setting name that contains the client secret of the relying party application.
      - `client_secret_certificate_issuer` - (Optional) An alternative to the client secret thumbprint, that is the issuer of a certificate used for signing purposes. This property acts as a replacement for the Client Secret Certificate Thumbprint. It is also optional.
      - `client_secret_certificate_subject_alternative_name` - (Optional) An alternative to the client secret thumbprint, that is the subject alternative name of a certificate used for signing purposes. This property acts as a replacement for the Client Secret Certificate Thumbprint. It is also optional.
    - `login` - (Optional) The login settings for the Azure Active Directory provider. The `login` block supports the following:
      - `login_parameters` - (Optional) Login parameters to send to the OpenID Connect authorization endpoint when a user logs in. Each parameter must be in the form "key=value".
      - `disable_www_authenticate` - (Optional) `true` if the www-authenticate provider should be omitted from the request; otherwise, `false`.
    - `validation` - (Optional) The configuration settings of the Azure Active Directory token validation flow. The `validation` block supports the following:
      - `jwt_claim_checks` - (Optional) The configuration settings of the checks that should be made while validating the JWT Claims. The `jwt_claim_checks` block supports the following:
        - `allowed_groups` - (Optional) The list of the allowed groups.
        - `allowed_client_applications` - (Optional) The list of the allowed client applications.
      - `allowed_audiences` - (Optional) The list of audiences that can make successful authentication/authorization requests.
      - `default_authorization_policy` - (Optional) The configuration settings of the default authorization policy. The `default_authorization_policy` block supports the following:
        - `allowed_applications` - (Optional) The configuration settings of the Azure Active Directory allowed applications.
        - `allowed_principals` - (Optional) The configuration settings of the Azure Active Directory allowed principals. The `allowed_principals` block supports the following:
          - `groups` - (Optional) The list of the allowed groups.
          - `identities` - (Optional) The list of the allowed identities.
  - `facebook` - (Optional) The configuration settings of the Facebook provider. The `facebook` block supports the following:
    - `enabled` - (Optional) `false` if the Facebook provider should not be enabled despite the set registration; otherwise, `true`.
    - `graph_api_version` - (Optional) The version of the Facebook api to be used while logging in.
    - `registration` - (Optional) The configuration settings of the app registration for the Facebook provider. The `registration` block supports the following:
      - `app_id` - (Optional) The App ID of the app used for login.
      - `app_secret_setting_name` - (Optional) The app setting name that contains the app secret.
    - `login` - (Optional) The configuration settings of the login flow. The `login` block supports the following:
      - `scopes` - (Optional) A list of the scopes that should be requested while authenticating.
  - `github` - (Optional) The configuration settings of the GitHub provider. The `github` block supports the following:
    - `enabled` - (Optional) `false` if the GitHub provider should not be enabled despite the set registration; otherwise, `true`.
    - `registration` - (Optional) The configuration settings of the app registration for the GitHub provider. The `registration` block supports the following:
      - `client_id` - (Optional) The Client ID of the app used for login.
      - `client_secret_setting_name` - (Optional) The app setting name that contains the client secret.
    - `login` - (Optional) The configuration settings of the login flow. The `login` block supports the following:
      - `scopes` - (Optional) A list of the scopes that should be requested while authenticating.
  - `google` - (Optional) The configuration settings of the Google provider.
    - `enabled` - (Optional) `false` if the Google provider should not be enabled despite the set registration; otherwise, `true`.
    - `registration` - (Optional) The configuration settings of the app registration for the Google provider. The `registration` block supports the following:
      - `client_id` - (Optional) The Client ID of the app used for login.
      - `client_secret_setting_name` - (Optional) The app setting name that contains the client secret.
    - `login` - (Optional) The configuration settings of the login flow. The `login` block supports the following:
      - `scopes` - (Optional) A list of the scopes that should be requested while authenticating.
    - `validation` - (Optional) The configuration settings of the Azure Active Directory token validation flow. The `validation` block supports the following:
      - `allowed_audiences` - (Optional) The configuration settings of the allowed list of audiences from which to validate the JWT token.
  - `twitter` - (Optional) The configuration settings of the Twitter provider. The `twitter` block supports the following:
    - `enabled` - (Optional) `false` if the Twitter provider should not be enabled despite the set registration; otherwise, `true`.
    - `registration` - (Optional) The configuration settings of the app registration for the Twitter provider. The `registration` block supports the following:
      - `consumer_key` - (Required) The OAuth 1.0a consumer key of the Twitter application used for sign-in. This setting is required for enabling Twitter Sign-In. Twitter Sign-In documentation: https://dev.twitter.com/web/sign-in
      - `consumer_secret_setting_name` - (Optional) The app setting name that contains the OAuth 1.0a consumer secret of the Twitter application used for sign-in.
  - `apple` - (Optional) The configuration settings of the Apple provider. The `apple` block supports the following:
    - `enabled` - (Optional) `false` if the Apple provider should not be enabled despite the set registration; otherwise, `true`.
    - `registration` - (Optional) The configuration settings of the Apple registration. The `registration` block supports the following:
      - `client_id` - (Optional) The Client ID of the app used for login.
      - `client_secret_setting_name` - (Optional) The app setting name that contains the client secret.
    - `login` - (Optional) The configuration settings of the login flow. The `login` block supports the following:
      - `scopes` - (Optional) A list of the scopes that should be requested while authenticating.
  - `azure_static_web_apps` - (Optional) The configuration settings of the Azure Static Web Apps provider. The `azure_static_web_apps` block supports the following:
    - `enabled` - (Optional) `false` if the Azure Static Web Apps provider should not be enabled despite the set registration; otherwise, `true`.
    - `registration` - (Optional) The configuration settings of the Azure Static Web Apps registration. The `registration` block supports the following:
      - `client_id` - (Optional) The Client ID of the app used for login.
  - `custom_open_id_connect_providers` - (Optional) The map of the name of the alias of each custom Open ID Connect provider to the configuration settings of the custom Open ID Connect provider. The `custom_open_id_connect_providers`'s value supports the following:
    - `enabled` - (Optional) `false` if the custom Open ID provider provider should not be enabled; otherwise, `true`.
    - `registration` - (Optional) The configuration settings of the app registration for the custom Open ID Connect provider. The `registration` block supports the following:
      - `client_id` - (Optional) The client id of the custom Open ID Connect provider.
      - `client_credential` - (Optional) The authentication credentials of the custom Open ID Connect provider. The `client_credential` block supports the following:
        - `method` - (Optional) The method that should be used to authenticate the user. Possible values `ClientSecretPost`.
        - `client_secret_setting_name` - (Optional) The app setting that contains the client secret for the custom Open ID Connect provider.
      - `open_id_connect_configuration` - (Optional) The configuration settings of the endpoints used for the custom Open ID Connect provider. The `open_id_connect_configuration` block supports the following:
        - `authorization_endpoint` - (Optional) The endpoint to be used to make an authorization request.
        - `certification_uri` - (Optional) The endpoint that provides the keys necessary to validate the token.
        - `issuer` - (Optional) The endpoint that issues the token.
        - `token_endpoint` - (Optional) The endpoint to be used to request a token.
        - `well_known_open_id_configuration` - (Optional) The endpoint that contains all the configuration endpoints for the provider.
    - `login` - (Optional) The configuration settings of the login flow of the custom Open ID Connect provider. The `login` block supports the following:
      - `name_claim_type` - (Optional) The name of the claim that contains the users name.
      - `scopes` - (Optional) A list of the scopes that should be requested while authenticating.

---
`login` - The configuration settings of the login flow of users using ContainerApp Service Authentication/Authorization. The `login` block supports the following:
  - `routes` - (Optional) The routes that specify the endpoints used for login and logout requests. The `routes` block supports the following:
    - `logout_endpoint` - (Optional) The endpoint at which a logout request should be made.
  - `token_store` - (Optional) The configuration settings of the token store. The `token_store` block supports the following:
    - `enabled` - (Optional) `true` to durably store platform-specific security tokens that are obtained during login flows; otherwise, `false`.
    - `token_refresh_extension_hours` - (Optional) The number of hours after session token expiration that a session token can be used to call the token refresh API
    - `azure_blob_storage` - (Optional) The configuration settings of the storage of the tokens if blob storage is used. The `azure_blob_storage` block supports the following:
      - `sas_url_setting_name` - (Required) The name of the app secrets containing the SAS URL of the blob storage containing the tokens.
  - `preserve_url_fragments_for_logins` - (Optional) `true` if the fragments from the request are preserved after the login request is made; otherwise, `false`.
  - `allowed_external_redirect_urls` - (Optional) External URLs that can be redirected to as part of logging in or logging out of the app. Note that the query string part of the URL is ignored. This is an advanced setting typically only needed by Windows Store application backends. Note that URLs within the current domain are always implicitly allowed.
  - `cookie_expiration` - (Optional) The configuration settings of the session cookie's expiration. The `cookie_expiration` block supports the following:
    - `convention` - (Optional) The convention used when determining the session cookie's expiration.
    - `time_to_expiration` - (Optional) The time after the request is made when the session cookie should expire.
  - `nonce` - (Optional) The configuration settings of the nonce used in the login flow. The `nonce` block supports the following:
    - `validate_nonce` - (Optional) `true` if the nonce should not be validated while completing the login flow; otherwise, `false`.
    - `nonce_expiration_interval` - (Optional) The time after the request is made when the nonce should expire.

Type:

```hcl
map(object({
    name = string
    platform = optional(object({
      enabled         = optional(bool)
      runtime_version = optional(string)
    }))
    global_validation = optional(object({
      unauthenticated_client_action = optional(string)
      redirect_to_provider          = optional(string)
      exclude_paths                 = optional(list(string))
    }))
    identity_providers = optional(object({
      azure_active_directory = optional(object({
        enabled = optional(bool)
        registration = optional(object({
          open_id_issuer                                     = optional(string)
          client_id                                          = optional(string)
          client_secret_setting_name                         = optional(string)
          client_secret_certificate_issuer                   = optional(string)
          client_secret_certificate_subject_alternative_name = optional(string)
          client_secret_certificate_thumbprint               = optional(string)
        }))
        login = optional(object({
          login_parameters         = list(string)
          disable_www_authenticate = bool
        }))
        validation = optional(object({
          jwt_claim_checks = optional(object({
            allowed_groups              = optional(list(string))
            allowed_client_applications = optional(list(string))
          }))
          allowed_audiences = optional(list(string))
          default_authorization_policy = optional(object({
            allowed_principals = optional(object({
              groups     = optional(list(string))
              identities = optional(list(string))
            }))
            allowed_applications = optional(list(string))
          }))
        }))
        is_auto_provisioned = optional(bool)
      }))
      facebook = optional(object({
        enabled = optional(bool)
        registration = optional(object({
          app_id                  = optional(string)
          app_secret_setting_name = optional(string)
        }))
        graph_api_version = optional(string)
        login = optional(object({
          scopes = list(string)
        }))
      }))
      github = optional(object({
        enabled = optional(bool)
        registration = optional(object({
          client_id                  = optional(string)
          client_secret_setting_name = optional(string)
        }))
        login = optional(object({
          scopes = list(string)
        }))
      }))
      google = optional(object({
        enabled = optional(bool)
        registration = optional(object({
          client_id                  = optional(string)
          client_secret_setting_name = optional(string)
        }))
        login = optional(object({
          scopes = list(string)
        }))
        validation = optional(object({
          allowed_audiences = list(string)
        }))
      }))
      twitter = optional(object({
        enabled = optional(bool)
        registration = optional(object({
          consumer_key                 = string
          consumer_secret_setting_name = optional(string)
        }))
      }))
      apple = optional(object({
        enabled = optional(bool)
        registration = optional(object({
          client_id                  = string
          client_secret_setting_name = optional(string)
        }))
        login = optional(object({
          scopes = list(string)
        }))
      }))
      azure_static_web_apps = optional(object({
        enabled = optional(bool)
        registration = optional(object({
          client_id = string
        }))
      }))
      custom_open_id_connect_providers = optional(map(object({
        enabled = optional(bool)
        registration = optional(object({
          client_id = optional(string)
          client_credential = optional(object({
            method                     = string
            client_secret_setting_name = string
          }))
          open_id_connect_configuration = optional(object({
            authorization_endpoint           = string
            token_endpoint                   = string
            issuer                           = string
            certification_uri                = string
            well_known_open_id_configuration = optional(string)
          }))
        }))
        login = optional(object({
          name_claim_type = string
          scopes          = list(string)
        }))
      })), {})
    }))
    login = optional(object({
      routes = optional(object({
        logout_endpoint = string
      }))
      token_store = optional(object({
        enabled                       = bool
        token_refresh_extension_hours = number
        azure_blob_storage = optional(object({
          sas_url_setting_name = string
        }))
      }))
      preserve_url_fragments_for_logins = optional(bool)
      allowed_external_redirect_urls    = optional(list(string))
      cookie_expiration = optional(object({
        convention         = optional(string)
        time_to_expiration = optional(string)
      }))
      nonce = optional(object({
        validate_nonce            = bool
        nonce_expiration_interval = string
      }))
    }))
    http_settings = optional(object({
      require_https = optional(bool)
      forward_proxy = optional(object({
        convention               = optional(string)
        custom_host_header_name  = optional(string)
        custom_proto_header_name = optional(string)
      }))
      routes = optional(object({
        api_prefix = string
      }))
    }))
    encryption_settings = optional(object({
      container_app_auth_encryption_secret_name = optional(string)
      container_app_auth_signing_secret_name    = optional(string)
    }))
  }))
```

Default: `{}`

### <a name="input_dapr"></a> [dapr](#input\_dapr)

Description: - `app_id` - (Optional) The Dapr Application Identifier.
- `app_port` - (Optional) The port which the application is listening on. This is the same as the `ingress` port.
- `app_protocol` - (Optional) The protocol for the app. Possible values include `http` and `grpc`. Defaults to `http`.
- `enable_api_logging` - (Optional) Enable API logging. Defaults to `false`.
- `enabled` - (Optional) Enable Dapr for the application. Defaults to `false`.
- `http_max_request_size` - (Optional) The maximum allowed HTTP request size in bytes.
- `http_read_buffer_size` - (Optional) The size of the buffer used for reading the HTTP request body in bytes.
- `log_level` - (Optional) The log level for Dapr. Possible values include "debug", "info", "warn", "error", and "fatal".

Type:

```hcl
object({
    app_id                = optional(string)
    app_port              = optional(number)
    app_protocol          = optional(string, "http")
    enable_api_logging    = optional(bool, false)
    enabled               = optional(bool, false)
    http_max_request_size = optional(number)
    http_read_buffer_size = optional(number)
    log_level             = optional(string, "info")
  })
```

Default: `null`

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see <https://aka.ms/avm/telemetryinfo>.  
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

### <a name="input_identity_settings"></a> [identity\_settings](#input\_identity\_settings)

Description: A list of identity settings for the Container App.

---
`identity_settings` block supports the following:
- `identity` - (Required) The resource ID of the user-assigned managed identity.
- `lifecycle` - (Required) The lifecycle state of the identity. Possible values are `Init`, `None`, `Retain` and `All`. Defaults to `All`.

Type:

```hcl
list(object({
    identity  = string
    lifecycle = optional(string, "All")
  }))
```

Default: `null`

### <a name="input_ingress"></a> [ingress](#input\_ingress)

Description:   
This object defines the ingress properties for the container app:

- `allow_insecure_connections` - (Optional) Should this ingress allow insecure connections? Defaults to `false`.
- `client_certificate_mode` - (Optional) The mode for client certificate authentication. Possible values include `optional` and `required`.
- `exposed_port` - (Optional) The exposed port on the container for the Ingress traffic. Defaults to `0`.
- `external_enabled` - (Optional) Are connections to this Ingress from outside the Container App Environment enabled? Defaults to `false`.
- `target_port` - (Required) The target port on the container for the Ingress traffic. Defaults to `Auto`.
- `transport` - (Optional) The transport method for the Ingress. Possible values include `auto`, `http`, `http2`, and `tcp`. Defaults to `auto`.

---
`traffic_weight` block supports the following:
- `label` - (Optional) The label to apply to the revision as a name prefix for routing traffic.
- `latest_revision` - (Optional) This traffic Weight relates to the latest stable Container Revision. Defaults to `false`.
- `revision_suffix` - (Optional) The suffix string to which this `traffic_weight` applies.
- `percentage` - (Required) The percentage of traffic which should be sent according to this configuration.

---
`cors_policy` block supports the following:
- `allow_credentials` - (Optional) Indicates whether the browser should include credentials when making a request. Defaults to `false`.
- `allowed_headers` - (Optional) List of headers that can be used when making the actual request.
- `allowed_methods` - (Optional) List of HTTP methods that can be used when making the actual request.
- `allowed_origins` - (Optional) List of origins that are allowed to access the resource.
- `expose_headers` - (Optional) List of response headers that can be exposed when making the actual request.
- `max_age` - (Optional) The maximum number of seconds the results of a preflight request can be cached.

---
`custom_domain` block supports the following:
- `certificate_binding_type` - (Optional) The Binding type. Possible values include `Disabled` and `SniEnabled`. Defaults to `Disabled`.
- `certificate_id` - (Optional) The ID of the Container App Environment Certificate.
- `name` - (Optional) The hostname of the Certificate. Must be the CN or a named SAN in the certificate.

---
`ip_restrictions` block supports the following:
- `action` - (Optional) The action to take when the IP security restriction is triggered. Possible values include `allow` and `deny`.
- `description` - (Optional) A description for the IP security restriction.
- `ip_range` - (Optional) The IP address range for the security restriction.
- `name` - (Optional) The name for the IP security restriction.

---
`sticky_sessions` block supports the following:
- `affinity` - (Optional) The affinity type for sticky sessions. Possible values include `None`, `ClientIP`, and `Server`.

Type:

```hcl
object({
    allow_insecure_connections = optional(bool, false)
    client_certificate_mode    = optional(string)
    exposed_port               = optional(number, 0)
    external_enabled           = optional(bool, false)
    target_port                = optional(number)
    transport                  = optional(string, "auto")

    traffic_weight = list(object({
      label           = optional(string)
      latest_revision = optional(bool, false)
      revision_suffix = optional(string)
      percentage      = number
    }))

    additional_port_mappings = optional(list(object({
      exposed_port = number
      external     = bool
      target_port  = number
    })))

    cors_policy = optional(object({
      allow_credentials = optional(bool, false)
      allowed_headers   = optional(list(string))
      allowed_methods   = optional(list(string))
      allowed_origins   = optional(list(string))
      expose_headers    = optional(list(string))
      max_age           = optional(number)
    }), null)

    custom_domain = optional(object({
      certificate_binding_type = optional(string)
      certificate_id           = optional(string)
      name                     = optional(string)
    }))

    ip_restrictions = optional(list(object({
      action      = optional(string)
      description = optional(string)
      ip_range    = optional(string)
      name        = optional(string)
    })))

    sticky_sessions = optional(object({
      affinity = optional(string, "none")
    }))
  })
```

Default: `null`

### <a name="input_location"></a> [location](#input\_location)

Description: Azure region where the resource should be deployed. If null, the location will be inferred from the resource group location. This variable would be required in v1.0.0.

Type: `string`

Default: `null`

### <a name="input_lock"></a> [lock](#input\_lock)

Description:   Controls the Resource Lock configuration for this resource. The following properties can be specified:

  - `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
  - `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.

Type:

```hcl
object({
    kind = string
    name = optional(string, null)
  })
```

Default: `null`

### <a name="input_managed_identities"></a> [managed\_identities](#input\_managed\_identities)

Description: Configurations for managed identities in Azure. This variable allows you to specify both system-assigned and user-assigned managed identities for resources that support identity-based authentication.

- `system_assigned` - (Optional) A boolean flag indicating whether to enable the system-assigned managed identity. Defaults to `false`.
- `user_assigned_resource_ids` - (Optional) A set of user-assigned managed identity resource IDs to be associated with the resource.

Type:

```hcl
object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
```

Default: `{}`

### <a name="input_max_inactive_revisions"></a> [max\_inactive\_revisions](#input\_max\_inactive\_revisions)

Description: (Optional). Max inactive revisions a Container App can have.

Type: `number`

Default: `0`

### <a name="input_registries"></a> [registries](#input\_registries)

Description:
- `identity` - (Optional) Resource ID for the User Assigned Managed identity to use when pulling from the Container Registry.
- `password_secret_name ` - (Optional) The name of the Secret Reference containing the password value for this user on the Container Registry, `username` must also be supplied.
- `server` - (Optional) The hostname for the Container Registry.
- `username` - (Optional) The username to use for this Container Registry, `password_secret_name` must also be supplied.

Type:

```hcl
list(object({
    identity             = optional(string)
    password_secret_name = optional(string)
    server               = optional(string)
    username             = optional(string)
  }))
```

Default: `null`

### <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id)

Description: (Optional) The id of the resource group in which the Container App Environment is to be created. Set only when you see recreation in Terraform plan caused by known after apply value assigned to `azapi_resource.container_app.parent_id`(when use this module along with `depends_on` another resource, all data source in this module would be defer to the apply time, which causes `data.azapi_client_config.current`'s values be `known after apply`). Changing this forces a new resource to be created.

Type: `string`

Default: `null`

### <a name="input_revision_mode"></a> [revision\_mode](#input\_revision\_mode)

Description: (Required) The revisions operational mode for the Container App. Possible values include `Single` and `Multiple`. In `Single` mode, a single revision is in operation at any given time. In `Multiple` mode, more than one revision can be active at a time and can be configured with load distribution via the `traffic_weight` block in the `ingress` configuration.

Type: `string`

Default: `"Single"`

### <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments)

Description:   A map of role assignments to create on the <RESOURCE>. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

  - `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
  - `principal_id` - The ID of the principal to assign the role to.
  - `description` - (Optional) The description of the role assignment.
  - `skip_service_principal_aad_check` - (Optional) If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
  - `condition` - (Optional) The condition which will be used to scope the role assignment.
  - `condition_version` - (Optional) The version of the condition syntax. Leave as `null` if you are not using a condition, if you are then valid values are '2.0'.
  - `delegated_managed_identity_resource_id` - (Optional) The delegated Azure Resource Id which contains a Managed Identity. Changing this forces a new resource to be created. This field is only used in cross-tenant scenario.
  - `principal_type` - (Optional) The type of the `principal_id`. Possible values are `User`, `Group` and `ServicePrincipal`. It is necessary to explicitly set this attribute when creating role assignments if the principal creating the assignment is constrained by ABAC rules that filters on the PrincipalType attribute.

  > Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.

Type:

```hcl
map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string)
    condition_version                      = optional(string)
    delegated_managed_identity_resource_id = optional(string)
    principal_type                         = optional(string)
  }))
```

Default: `{}`

### <a name="input_runtime"></a> [runtime](#input\_runtime)

Description: Runtime configuration for the Container App.

---
`runtime` block supports the following:
- `java` - (Optional) Java runtime configuration.

---
`java` block supports the following:
- `enable_metrics` - (Optional) Whether to enable Java metrics collection. Defaults to `false`.

Type:

```hcl
object({
    java = optional(object({
      enable_metrics = optional(bool, false)
    }))
  })
```

Default: `null`

### <a name="input_secrets"></a> [secrets](#input\_secrets)

Description:
- `key_vault_secret_id` - (Optional) The URL of the Azure Key Vault containing the secret. Required when `identity` is specified.
- `identity` - (Optional) The identity associated with the secret.
- `name` - (Required) The secret name.
- `value` - (Required) The value for this secret.

Type:

```hcl
map(object({
    identity            = optional(string)
    key_vault_secret_id = optional(string)
    name                = string
    value               = string
  }))
```

Default: `null`

### <a name="input_secrets_version"></a> [secrets\_version](#input\_secrets\_version)

Description: Version number for the secrets. Must set this version number to a different value to trigger an update on secrets. Defaults to `0`.

Type: `number`

Default: `0`

### <a name="input_service"></a> [service](#input\_service)

Description: Service configuration for the Container App.

---
`service` block supports the following:
- `type` - (Required) The type of service. Possible values include service types supported by Azure Container Apps.

Type:

```hcl
object({
    type = string
  })
```

Default: `null`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: Custom tags to apply to the resource.

Type: `map(string)`

Default: `null`

### <a name="input_timeouts"></a> [timeouts](#input\_timeouts)

Description: - `create` - (Defaults to 30 minutes) Used when creating the Container App. Defaults to `30m`.
- `delete` - (Defaults to 30 minutes) Used when deleting the Container App. Defaults to `30m`.
- `read` - (Defaults to 5 minutes) Used when retrieving the Container App. Defaults to `5m`.
- `update` - (Defaults to 30 minutes) Used when updating the Container App. Defaults to `30m`.

Type:

```hcl
object({
    create = optional(string, "30m")
    delete = optional(string, "30m")
    read   = optional(string, "5m")
    update = optional(string, "30m")
  })
```

Default: `null`

### <a name="input_workload_profile_name"></a> [workload\_profile\_name](#input\_workload\_profile\_name)

Description: Workload profile name to pin for container app execution.  If not set, workload profiles are not used.

Type: `string`

Default: `null`

## Outputs

The following outputs are exported:

### <a name="output_custom_domain_verification_id"></a> [custom\_domain\_verification\_id](#output\_custom\_domain\_verification\_id)

Description: The custom domain verification ID for the Container App.

### <a name="output_custom_domains"></a> [custom\_domains](#output\_custom\_domains)

Description: The custom domains configured for the Container App.

### <a name="output_environment_id"></a> [environment\_id](#output\_environment\_id)

Description: The ID of the Container App Environment.

### <a name="output_fqdn_url"></a> [fqdn\_url](#output\_fqdn\_url)

Description: https url that contains ingress's fqdn, could be used to access the deployed app.

### <a name="output_identity"></a> [identity](#output\_identity)

Description: The identities assigned to the Container App.

### <a name="output_latest_ready_revision_name"></a> [latest\_ready\_revision\_name](#output\_latest\_ready\_revision\_name)

Description: The name of the latest ready revision of the Container App.

### <a name="output_latest_revision_fqdn"></a> [latest\_revision\_fqdn](#output\_latest\_revision\_fqdn)

Description: The FQDN of the latest revision of the Container App.

### <a name="output_latest_revision_name"></a> [latest\_revision\_name](#output\_latest\_revision\_name)

Description: The name of the latest revision of the Container App.

### <a name="output_location"></a> [location](#output\_location)

Description: The Azure Region where the Container App is located.

### <a name="output_name"></a> [name](#output\_name)

Description: The name of the Container App.

### <a name="output_outbound_ip_addresses"></a> [outbound\_ip\_addresses](#output\_outbound\_ip\_addresses)

Description: The outbound IP addresses of the Container App.

### <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id)

Description: Resource ID of container app resource created by this module.

## Modules

The following Modules are called:

### <a name="module_avm_interfaces"></a> [avm\_interfaces](#module\_avm\_interfaces)

Source: Azure/avm-utl-interfaces/azure

Version: 0.2.0

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->