resource "azapi_resource" "this" {
  name      = var.name
  parent_id = var.container_app_resource_id
  type      = "Microsoft.App/containerApps/authConfigs@2025-01-01"
  body = {
    properties = {
      platform = var.platform == null ? null : {
        enabled        = try(var.platform.enabled, null)
        runtimeVersion = try(var.platform.runtime_version, null)
      }
      encryptionSettings = var.encryption_settings == null ? {} : {
        containerAppAuthEncryptionSecretName = try(var.encryption_settings.container_app_auth_encryption_secret_name, null)
        containerAppAuthSigningSecretName    = try(var.encryption_settings.container_app_auth_signing_secret_name, null)
      }
      globalValidation = var.global_validation == null ? null : {
        unauthenticatedClientAction = try(var.global_validation.unauthenticated_client_action, null)
        excludedPaths               = try(var.global_validation.exclude_paths, null)
        redirectToProvider          = try(var.global_validation.redirect_to_provider, null)
      }
      identityProviders = var.identity_providers == null ? null : {
        azureActiveDirectory = var.identity_providers.azure_active_directory == null ? null : {
          enabled = try(var.identity_providers.azure_active_directory.enabled, null)
          registration = var.identity_providers.azure_active_directory.registration == null ? null : {
            openIdIssuer                                  = try(var.identity_providers.azure_active_directory.registration.open_id_issuer, null)
            clientId                                      = try(var.identity_providers.azure_active_directory.registration.client_id, null)
            clientSecretSettingName                       = try(var.identity_providers.azure_active_directory.registration.client_secret_setting_name, null)
            clientSecretCertificateThumbprint             = try(var.identity_providers.azure_active_directory.registration.client_secret_certificate_thumbprint, null)
            clientSecretCertificateSubjectAlternativeName = try(var.identity_providers.azure_active_directory.registration.client_secret_certificate_subject_alternative_name, null)
            clientSecretCertificateIssuer                 = try(var.identity_providers.azure_active_directory.registration.client_secret_certificate_issuer, null)
          }
          login = var.identity_providers.azure_active_directory.login == null ? null : {
            loginParameters        = try(var.identity_providers.azure_active_directory.login.login_parameters, null)
            disableWWWAuthenticate = try(var.identity_providers.azure_active_directory.login.disable_www_authenticate, null)
          }
          validation = var.identity_providers.azure_active_directory.validation == null ? null : {
            jwtClaimChecks = var.identity_providers.azure_active_directory.validation.jwt_claim_checks == null ? null : {
              allowedGroups             = try(var.identity_providers.azure_active_directory.validation.jwt_claim_checks.allowed_groups, null)
              allowedClientApplications = try(var.identity_providers.azure_active_directory.validation.jwt_claim_checks.allowed_client_applications, null)
            }
            allowedAudiences = try(var.identity_providers.azure_active_directory.validation.allowed_audiences, null)
            defaultAuthorizationPolicy = var.identity_providers.azure_active_directory.validation.default_authorization_policy == null ? null : {
              allowedPrincipals = var.identity_providers.azure_active_directory.validation.default_authorization_policy.allowed_principals == null ? null : {
                groups     = try(var.identity_providers.azure_active_directory.validation.default_authorization_policy.allowed_principals.groups, null)
                identities = try(var.identity_providers.azure_active_directory.validation.default_authorization_policy.allowed_principals.identities, null)
              }
              allowedApplications = try(var.identity_providers.azure_active_directory.validation.default_authorization_policy.allowed_applications, null)
            }
          }
          isAutoProvisioned = try(var.identity_providers.azure_active_directory.is_auto_provisioned, null)
        }
        facebook = var.identity_providers.facebook == null ? null : {
          enabled = try(var.identity_providers.facebook.enabled, null)
          registration = var.identity_providers.facebook.registration == null ? null : {
            appId                = try(var.identity_providers.facebook.registration.app_id, null)
            appSecretSettingName = try(var.identity_providers.facebook.registration.app_secret_setting_name, null)
          }
          graphApiVersion = try(var.identity_providers.facebook.graph_api_version, null)
          login = var.identity_providers.facebook.login == null ? null : {
            scopes = try(var.identity_providers.facebook.login.scopes, null)
          }
        }
        gitHub = var.identity_providers.github == null ? null : {
          enabled = try(var.identity_providers.github.enabled, null)
          registration = var.identity_providers.github.registration == null ? null : {
            clientId                = try(var.identity_providers.github.registration.client_id, null)
            clientSecretSettingName = try(var.identity_providers.github.registration.client_secret_setting_name, null)
          }
          login = var.identity_providers.github.login == null ? null : {
            scopes = try(var.identity_providers.github.login.scopes, null)
          }
        }
        google = var.identity_providers.google == null ? null : {
          enabled = try(var.identity_providers.google.enabled, null)
          registration = var.identity_providers.google.registration == null ? null : {
            clientId                = try(var.identity_providers.google.registration.client_id, null)
            clientSecretSettingName = try(var.identity_providers.google.registration.client_secret_setting_name, null)
          }
          login = var.identity_providers.google.login == null ? null : {
            scopes = try(var.identity_providers.google.login.scopes, null)
          }
          validation = var.identity_providers.google.validation == null ? null : {
            allowedAudiences = try(var.identity_providers.google.validation.allowed_audiences, null)
          }
        }
        twitter = var.identity_providers.twitter == null ? null : {
          enabled = try(var.identity_providers.twitter.enabled, null)
          registration = var.identity_providers.twitter.registration == null ? null : {
            consumerKey               = try(var.identity_providers.twitter.registration.consumer_key, null)
            consumerSecretSettingName = try(var.identity_providers.twitter.registration.consumer_secret_setting_name, null)
          }
        }
        apple = var.identity_providers.apple == null ? null : {
          enabled = try(var.identity_providers.apple.enabled, null)
          registration = var.identity_providers.apple.registration == null ? null : {
            clientId                = try(var.identity_providers.apple.registration.client_id, null)
            clientSecretSettingName = try(var.identity_providers.apple.registration.client_secret_setting_name, null)
          }
          login = var.identity_providers.apple.login == null ? null : {
            scopes = try(var.identity_providers.apple.login.scopes, null)
          }
        }
        azureStaticWebApps = var.identity_providers.azure_static_web_apps == null ? null : {
          enabled = try(var.identity_providers.azure_static_web_apps.enabled, null)
          registration = var.identity_providers.azure_static_web_apps.registration == null ? null : {
            clientId = try(var.identity_providers.azure_static_web_apps.registration.client_id, null)
          }
        }
        customOpenIdConnectProviders = var.identity_providers.custom_open_id_connect_providers == null ? null : { for k, v in var.identity_providers.custom_open_id_connect_providers : k =>
          {
            enabled = try(v.enabled, null)
            registration = v.registration == null ? null : {
              clientId = try(v.registration.client_id, null)
              clientCredential = v.registration.client_credential == null ? null : {
                method                  = try(v.registration.client_credential.method, null)
                clientSecretSettingName = try(v.registration.client_credential.client_secret_setting_name, null)
              }
              openIdConnectConfiguration = v.registration.open_id_connect_configuration == null ? null : {
                authorizationEndpoint        = try(v.registration.open_id_connect_configuration.authorization_endpoint, null)
                tokenEndpoint                = try(v.registration.open_id_connect_configuration.token_endpoint, null)
                issuer                       = try(v.registration.open_id_connect_configuration.issuer, null)
                certificationUri             = try(v.registration.open_id_connect_configuration.certification_uri, null)
                wellKnownOpenIdConfiguration = try(v.registration.open_id_connect_configuration.well_known_open_id_configuration, null)
              }
            }
            login = v.login == null ? null : {
              nameClaimType = try(v.login.name_claim_type, null)
              scopes        = try(v.login.scopes, null)
            }
          }
        }
      }
      login = var.login == null ? null : {
        routes = var.login.routes == null ? null : {
          logoutEndpoint = try(var.login.routes.logout_endpoint, null)
        }
        tokenStore = var.login.token_store == null ? null : {
          enabled                    = try(var.login.token_store.enabled, null)
          tokenRefreshExtensionHours = try(var.login.token_store.token_refresh_extension_hours, null)
          azureBlobStorage = var.login.token_store.azure_blob_storage == null ? null : {
            sasUrlSettingName = try(var.login.token_store.azure_blob_storage.sas_url_setting_name, null)
          }
        }
        preserveUrlFragmentsForLogins = try(var.login.preserve_url_fragments_for_logins, null)
        allowedExternalRedirectUrls   = try(var.login.allowed_external_redirect_urls, null)
        cookieExpiration              = try(var.login.cookie_expiration, null)
        nonce = var.login.nonce == null ? null : {
          validateNonce           = try(var.login.nonce.validate_nonce, null)
          nonceExpirationInterval = try(var.login.nonce.nonce_expiration_interval, null)
        }
      }
      httpSettings = var.http_settings == null ? null : {
        requireHttps = try(var.http_settings.require_https, null)
        routes = var.http_settings.routes == null ? null : {
          apiPrefix = try(var.http_settings.routes.api_prefix, null)
        }
        forwardProxy = var.http_settings.forward_proxy == null ? null : {
          convention            = try(var.http_settings.forward_proxy.convention, null)
          customHostHeaderName  = try(var.http_settings.forward_proxy.custom_host_header_name, null)
          customProtoHeaderName = try(var.http_settings.forward_proxy.custom_proto_header_name, null)
        }
      }
    }
  }
  ignore_null_property = true
  retry                = var.retry

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}
