# AVM Interfaces module for locks and role assignments
module "avm_interfaces" {
  source  = "Azure/avm-utl-interfaces/azure"
  version = "0.6.0"

  enable_telemetry                          = var.enable_telemetry
  lock                                      = var.lock
  role_assignment_definition_lookup_enabled = var.role_assignment_definition_lookup_enabled
  role_assignment_definition_scope          = "/subscriptions/${data.azapi_client_config.this.subscription_id}"
  role_assignments                          = var.role_assignments
}

data "azapi_client_config" "this" {}

resource "azapi_resource" "this" {
  location  = var.location
  name      = var.name
  parent_id = var.parent_id
  type      = var.portal_dashboard_resource_type
  body = {
    properties = jsondecode(templatefile(var.template_file_path, local.all_template_file_variables))
  }
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  # `ignore_body_changes` is a write-only argument; collapsing an empty list to
  # `null` keeps the argument absent so the module still works on Terraform < 1.11.
  ignore_body_changes    = length(var.ignore_body_changes) > 0 ? var.ignore_body_changes : null
  ignore_null_property   = true
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = []
  retry                  = var.retry
  tags                   = var.tags
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  dynamic "timeouts" {
    for_each = var.timeouts != null ? { this = var.timeouts } : {}

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

# Role Assignments
#
# Note: there is no built-in Azure RBAC role specific to portal dashboards. Use
# the generic `Reader`, `Contributor` or `Owner` roles, or supply a custom role
# definition resource ID.
resource "azapi_resource" "role_assignment" {
  for_each = module.avm_interfaces.role_assignments_azapi

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

  dynamic "timeouts" {
    for_each = var.timeouts != null ? { this = var.timeouts } : {}

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }

  lifecycle {
    # principalType is server-resolved (User/ServicePrincipal/Group) when not
    # specified; ignore it to avoid perpetual drift.
    ignore_changes = [body.properties.principalType]
  }
}

# Lock
resource "azapi_resource" "lock" {
  count = var.lock != null ? 1 : 0

  name                   = module.avm_interfaces.lock_azapi.name
  parent_id              = azapi_resource.this.id
  type                   = module.avm_interfaces.lock_azapi.type
  body                   = module.avm_interfaces.lock_azapi.body
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = []
  retry                  = var.retry
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  dynamic "timeouts" {
    for_each = var.timeouts != null ? { this = var.timeouts } : {}

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }

  # Create the lock after the role assignments so it cannot interfere with
  # their creation, and let Terraform remove it first on destroy.
  depends_on = [azapi_resource.role_assignment]
}
