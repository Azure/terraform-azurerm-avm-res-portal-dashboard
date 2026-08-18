# Shared AVM interfaces (lock, role assignments) transformed into azapi resource
# payloads via the avm-utl-interfaces utility module.
module "interfaces" {
  source  = "Azure/avm-utl-interfaces/azure"
  version = "0.7.0"

  enable_telemetry                          = var.enable_telemetry
  lock                                      = var.lock
  role_assignment_definition_lookup_enabled = var.role_assignment_definition_lookup_enabled
  role_assignment_definition_scope          = local.role_assignment_definition_scope
  role_assignments                          = var.role_assignments
}

resource "azapi_resource" "lock" {
  count = var.lock != null ? 1 : 0

  name                   = coalesce(module.interfaces.lock_azapi.name, "lock-${var.lock.kind}")
  parent_id              = azapi_resource.this.id
  type                   = module.interfaces.lock_azapi.type
  body                   = module.interfaces.lock_azapi.body
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = []
  retry                  = var.retry
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  timeouts {
    create = var.timeouts.create
    delete = var.timeouts.delete
    read   = var.timeouts.read
    update = var.timeouts.update
  }

  depends_on = [azapi_resource.this]
}

resource "azapi_resource" "role_assignments" {
  for_each = module.interfaces.role_assignments_azapi

  name                   = each.value.name
  parent_id              = azapi_resource.this.id
  type                   = each.value.type
  body                   = each.value.body
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  ignore_null_property   = true
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = []
  retry                  = var.retry
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  timeouts {
    create = var.timeouts.create
    delete = var.timeouts.delete
    read   = var.timeouts.read
    update = var.timeouts.update
  }

  # Role assignment names are immutable GUIDs in Azure; they are replaced rather
  # than renamed. Ignoring `name` prevents a destroy/recreate (and the associated
  # RBAC outage) when a generated name is not yet known at plan time.
  lifecycle {
    ignore_changes = [name]
  }
  depends_on = [azapi_resource.this]
}
