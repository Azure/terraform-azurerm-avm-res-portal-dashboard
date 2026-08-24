# Local variables for resource group and dashboard names
locals {
  all_template_file_variables     = merge(local.default_template_file_variables, var.template_file_variables)
  default_template_file_variables = { name = var.name }
}
