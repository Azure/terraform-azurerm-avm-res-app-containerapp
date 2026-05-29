# Container App Auth Config submodule

This submodule manages a single [`Microsoft.App/containerApps/authConfigs`](https://learn.microsoft.com/azure/templates/microsoft.app/containerapps/authconfigs) resource attached to an existing Container App.

It exists to satisfy AVM specification [TFRMNFR1](https://azure.github.io/Azure-Verified-Modules/specs/tf/res/#id-tfrmnfr1---category-composition---subresources-as-submodules), which requires every ARM subresource of a resource module to be implemented as a Terraform submodule.

Normally consumers do not need to call this submodule directly: passing `auth_configs` to the parent `Azure/avm-res-app-containerapp/azurerm` module will instantiate it under the covers. The submodule can also be consumed independently when an auth config needs to be attached to a Container App that is managed outside of this module.

The submodule manages exactly one auth config per invocation. Cardinality is the caller's responsibility — use `for_each` or `count` on the `module` block to deploy more than one.
