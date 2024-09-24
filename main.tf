resource "azurerm_portal_dashboard" "dashboard" {
  dashboard_properties = templatefile(var.template_file_path, local.all_template_file_variables)
  location             = var.location
  name                 = local.dashboard_display_name
  resource_group_name  = var.resource_group_name
  tags                 = var.tags
}
