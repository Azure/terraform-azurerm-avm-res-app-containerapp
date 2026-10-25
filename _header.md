# terraform-azurerm-avm-res-app-containerapp

This is a template repo for Terraform Azure Verified Container App Modules.

This module *DOES NOT* contain other Container App related resource, including `azurerm_container_app_environment`.

## Upgrade notes

`location` is now required and cannot be null, even when telemetry is disabled. Callers that previously omitted it must explicitly pass their existing resource group's region. Use the same region as the existing Container App to avoid a location change.

The Interfaces dependency is upgraded from `0.5.0` to `0.9.0`. Role-assignment map keys and resource addresses are unchanged. Retain existing state and keys, and review the upgrade plan for unintended replacements.

The `azure-functions`, `dapr`, `secret_path`, and `simple` examples now use `Azure/avm-utl-naming/azure` `0.2.0` instead of `Azure/naming/azurerm`. Generated names may change for existing example deployments; retain their state and review replacement plans before applying.

Telemetry now uses subscription-scoped Azure deployments. With telemetry enabled, the deployment identity needs `Microsoft.Resources/deployments/read`, `Microsoft.Resources/deployments/write`, and `Microsoft.Resources/deployments/delete` at the active subscription scope. Existing telemetry state is forgotten without destruction; the old providers must remain available for the first initialization of existing state. See the [telemetry guidance](https://azure.github.io/Azure-Verified-Modules/help-support/telemetry/).
