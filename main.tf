data "azapi_client_config" "this" {}

resource "azapi_resource" "this" {
  location  = var.location
  name      = local.dashboard_display_name
  parent_id = local.resource_group_resource_id
  type      = var.resource_types.portal_dashboards
  body = {
    properties = jsondecode(templatefile(var.template_file_path, local.all_template_file_variables))
  }
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  # `ignore_body_changes` is a write-only argument; collapsing an empty list to
  # `null` keeps the argument absent so the module still works on Terraform < 1.11.
  ignore_body_changes    = length(var.ignore_body_changes.portal_dashboards) > 0 ? var.ignore_body_changes.portal_dashboards : null
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = []
  retry                  = var.retry
  tags                   = var.tags
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  timeouts {
    create = var.timeouts.create
    delete = var.timeouts.delete
    read   = var.timeouts.read
    update = var.timeouts.update
  }
}
