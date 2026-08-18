# Local variables for resource group and dashboard names
locals {
  all_template_file_variables     = merge(local.default_template_file_variables, var.template_file_variables)
  dashboard_display_name          = var.name
  default_template_file_variables = { name = var.name }
}

locals {
  # AzAPI addresses the parent by resource ID rather than by resource group name.
  resource_group_resource_id = "/subscriptions/${data.azapi_client_config.this.subscription_id}/resourceGroups/${var.resource_group_name}"
  # Subscription scope used by the interfaces module to resolve role definition
  # names to role definition resource IDs.
  role_assignment_definition_scope = "/subscriptions/${data.azapi_client_config.this.subscription_id}"
}
