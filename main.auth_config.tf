resource "azapi_resource" "auth_config" {
  for_each = var.auth_configs

  name      = each.value.name
  parent_id = azapi_resource.container_app.id
  type      = "Microsoft.App/containerApps/authConfigs@2025-01-01"
  body = {
    properties = {
      platform = each.value.platform == null ? null : {
        enabled        = try(each.value.platform.enabled, null)
        runtimeVersion = try(each.value.platform.runtime_version, null)
      }
      encryptionSettings = each.value.encryption_settings == null ? {} : {
        containerAppAuthEncryptionSecretName = try(each.value.encryption_settings.container_app_auth_encryption_secret_name, null)
        containerAppAuthSigningSecretName    = try(each.value.encryption_settings.container_app_auth_signing_secret_name, null)
      }
      globalValidation = each.value.global_validation == null ? null : {
        unauthenticatedClientAction = try(each.value.global_validation.unauthenticated_client_action, null)
        excludedPaths               = try(each.value.global_validation.exclude_paths, null)
        redirectToProvider          = try(each.value.global_validation.redirect_to_provider, null)
      }
      identityProviders = each.value.identity_providers == null ? null : {
        azureActiveDirectory = each.value.identity_providers.azure_active_directory == null ? null : {
          enabled = try(each.value.identity_providers.azure_active_directory.enabled, null)
          registration = each.value.identity_providers.azure_active_directory.registration == null ? null : {
            openIdIssuer                                  = try(each.value.identity_providers.azure_active_directory.registration.open_id_issuer, null)
            clientId                                      = try(each.value.identity_providers.azure_active_directory.registration.client_id, null)
            clientSecretSettingName                       = try(each.value.identity_providers.azure_active_directory.registration.client_secret_setting_name, null)
            clientSecretCertificateThumbprint             = try(each.value.identity_providers.azure_active_directory.registration.client_secret_certificate_thumbprint, null)
            clientSecretCertificateSubjectAlternativeName = try(each.value.identity_providers.azure_active_directory.registration.client_secret_certificate_subject_alternative_name, null)
            clientSecretCertificateIssuer                 = try(each.value.identity_providers.azure_active_directory.registration.client_secret_certificate_issuer, null)
          }
          login = each.value.identity_providers.azure_active_directory.login == null ? null : {
            loginParameters        = try(each.value.identity_providers.azure_active_directory.login.login_parameters, null)
            disableWWWAuthenticate = try(each.value.identity_providers.azure_active_directory.login.disable_www_authenticate, null)
          }
          validation = each.value.identity_providers.azure_active_directory.validation == null ? null : {
            jwtClaimChecks = each.value.identity_providers.azure_active_directory.validation.jwt_claim_checks == null ? null : {
              allowedGroups             = try(each.value.identity_providers.azure_active_directory.validation.jwt_claim_checks.allowed_groups, null)
              allowedClientApplications = try(each.value.identity_providers.azure_active_directory.validation.jwt_claim_checks.allowed_client_applications, null)
            }
            allowedAudiences = try(each.value.identity_providers.azure_active_directory.validation.allowed_audiences, null)
            defaultAuthorizationPolicy = each.value.identity_providers.azure_active_directory.validation.default_authorization_policy == null ? null : {
              allowedPrincipals = each.value.identity_providers.azure_active_directory.validation.default_authorization_policy.allowed_principals == null ? null : {
                groups     = try(each.value.identity_providers.azure_active_directory.validation.default_authorization_policy.allowed_principals.groups, null)
                identities = try(each.value.identity_providers.azure_active_directory.validation.default_authorization_policy.allowed_principals.identities, null)
              }
              allowedApplications = try(each.value.identity_providers.azure_active_directory.validation.default_authorization_policy.allowed_applications, null)
            }
          }
          isAutoProvisioned = try(each.value.identity_providers.azure_active_directory.is_auto_provisioned, null)
        }
        facebook = each.value.identity_providers.facebook == null ? null : {
          enabled = try(each.value.identity_providers.facebook.enabled, null)
          registration = each.value.identity_providers.facebook.registration == null ? null : {
            appId                = try(each.value.identity_providers.facebook.registration.app_id, null)
            appSecretSettingName = try(each.value.identity_providers.facebook.registration.app_secret_setting_name, null)
          }
          graphApiVersion = try(each.value.identity_providers.facebook.graph_api_version, null)
          login = each.value.identity_providers.facebook.login == null ? null : {
            scopes = try(each.value.identity_providers.facebook.login.scopes, null)
          }
        }
        gitHub = each.value.identity_providers.github == null ? null : {
          enabled = try(each.value.identity_providers.github.enabled, null)
          registration = each.value.identity_providers.github.registration == null ? null : {
            clientId                = try(each.value.identity_providers.github.registration.client_id, null)
            clientSecretSettingName = try(each.value.identity_providers.github.registration.client_secret_setting_name, null)
          }
          login = each.value.identity_providers.github.login == null ? null : {
            scopes = try(each.value.identity_providers.github.login.scopes, null)
          }
        }
        google = each.value.identity_providers.google == null ? null : {
          enabled = try(each.value.identity_providers.google.enabled, null)
          registration = each.value.identity_providers.google.registration == null ? null : {
            clientId                = try(each.value.identity_providers.google.registration.client_id, null)
            clientSecretSettingName = try(each.value.identity_providers.google.registration.client_secret_setting_name, null)
          }
          login = each.value.identity_providers.google.login == null ? null : {
            scopes = try(each.value.identity_providers.google.login.scopes, null)
          }
          validation = each.value.identity_providers.google.validation == null ? null : {
            allowedAudiences = try(each.value.identity_providers.google.validation.allowed_audiences, null)
          }
        }
        twitter = each.value.identity_providers.twitter == null ? null : {
          enabled = try(each.value.identity_providers.twitter.enabled, null)
          registration = each.value.identity_providers.twitter.registration == null ? null : {
            consumerKey               = try(each.value.identity_providers.twitter.registration.consumer_key, null)
            consumerSecretSettingName = try(each.value.identity_providers.twitter.registration.consumer_secret_setting_name, null)
          }
        }
        apple = each.value.identity_providers.apple == null ? null : {
          enabled = try(each.value.identity_providers.apple.enabled, null)
          registration = each.value.identity_providers.apple.registration == null ? null : {
            clientId                = try(each.value.identity_providers.apple.registration.client_id, null)
            clientSecretSettingName = try(each.value.identity_providers.apple.registration.client_secret_setting_name, null)
          }
          login = each.value.identity_providers.apple.login == null ? null : {
            scopes = try(each.value.identity_providers.apple.login.scopes, null)
          }
        }
        azureStaticWebApps = each.value.identity_providers.azure_static_web_apps == null ? null : {
          enabled = try(each.value.identity_providers.azure_static_web_apps.enabled, null)
          registration = each.value.identity_providers.azure_static_web_apps.registration == null ? null : {
            clientId = try(each.value.identity_providers.azure_static_web_apps.registration.client_id, null)
          }
        }
        customOpenIdConnectProviders = each.value.identity_providers.custom_open_id_connect_providers == null ? null : { for k, v in each.value.identity_providers.custom_open_id_connect_providers : k =>
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
      login = each.value.login == null ? null : {
        routes = each.value.login.routes == null ? null : {
          logoutEndpoint = try(each.value.login.routes.logout_endpoint, null)
        }
        tokenStore = each.value.login.token_store == null ? null : {
          enabled                    = try(each.value.login.token_store.enabled, null)
          tokenRefreshExtensionHours = try(each.value.login.token_store.token_refresh_extension_hours, null)
          azureBlobStorage = each.value.login.token_store.azure_blob_storage == null ? null : {
            sasUrlSettingName = try(each.value.login.token_store.azure_blob_storage.sas_url_setting_name, null)
          }
        }
        preserveUrlFragmentsForLogins = try(each.value.login.preserve_url_fragments_for_logins, null)
        allowedExternalRedirectUrls   = try(each.value.login.allowed_external_redirect_urls, null)
        cookieExpiration              = try(each.value.login.cookie_expiration, null)
        nonce = each.value.login.nonce == null ? null : {
          validateNonce           = try(each.value.login.nonce.validate_nonce, null)
          nonceExpirationInterval = try(each.value.login.nonce.nonce_expiration_interval, null)
        }
      }
      httpSettings = each.value.http_settings == null ? null : {
        requireHttps = try(each.value.http_settings.require_https, null)
        routes = each.value.http_settings.routes == null ? null : {
          apiPrefix = try(each.value.http_settings.routes.api_prefix, null)
        }
        forwardProxy = each.value.http_settings.forward_proxy == null ? null : {
          convention            = try(each.value.http_settings.forward_proxy.convention, null)
          customHostHeaderName  = try(each.value.http_settings.forward_proxy.custom_host_header_name, null)
          customProtoHeaderName = try(each.value.http_settings.forward_proxy.custom_proto_header_name, null)
        }
      }
    }
  }
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}
