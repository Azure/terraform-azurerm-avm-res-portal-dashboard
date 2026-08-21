# Dashboard-scope role assignments (var.role_assignments).
#
# Role assignments are created via the `role_assignments` submodule, which
# composes `Azure/avm-utl-interfaces/azure` to resolve role-definition IDs by
# name and to construct the AzAPI body.
#
# Note: there is no built-in Azure RBAC role specific to portal dashboards.
# Use the generic `Reader`, `Contributor` or `Owner` roles, or supply a custom
# role definition resource ID.
module "role_assignments" {
  source = "./modules/role_assignments"

  scope                                     = azapi_resource.this.id
  retry                                     = var.retry
  role_assignment_definition_lookup_enabled = var.role_assignment_definition_lookup_enabled
  role_assignments                          = var.role_assignments
  timeouts                                  = var.timeouts
  tracing_tags_header                       = var.enable_telemetry ? local.avm_azapi_header : null
}
