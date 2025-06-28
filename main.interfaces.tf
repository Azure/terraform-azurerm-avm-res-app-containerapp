module "avm_interfaces" {
  source  = "Azure/avm-utl-interfaces/azure"
  version = "0.2.0"

  lock                             = var.lock
  role_assignment_definition_scope = "/subscriptions/${data.azapi_client_config.current.subscription_id}"
  role_assignments                 = var.role_assignments
}

resource "azapi_resource" "role_assignments" {
  for_each = module.avm_interfaces.role_assignments_azapi

  name      = each.value.name
  parent_id = azapi_resource.container_app.id
  type      = each.value.type
  body      = each.value.body
}

resource "azapi_resource" "lock" {
  count = var.lock != null ? 1 : 0

  name      = module.avm_interfaces.lock_azapi.name != null ? module.avm_interfaces.lock_azapi.name : "lock-${azapi_resource.container_app.name}"
  parent_id = azapi_resource.container_app.id
  type      = module.avm_interfaces.lock_azapi.type
  body      = module.avm_interfaces.lock_azapi.body
}

moved {
  from = azurerm_management_lock.this[0]
  to   = azapi_resource.lock[0]
}

moved {
  from = azurerm_role_assignment.this
  to   = azapi_resource.role_assignments
}
