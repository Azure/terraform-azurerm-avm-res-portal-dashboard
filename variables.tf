# This is required for most resource modules
variable "location" {
  type        = string
  description = "Azure region where the resource should be deployed."
  nullable    = false
}

variable "name" {
  type        = string
  description = "The name of the dashboard."
  nullable    = false

  validation {
    condition     = can(regex("^[-a-zA-Z0-9]{0,64}$", var.name))
    error_message = "The dashboard name can only contain alphanumeric characters, hyphens, and has to be 64 characters or less."
  }
}

variable "resource_group_name" {
  type        = string
  description = "The resource group where the resources will be deployed."
  nullable    = false
}

variable "template_file_path" {
  type        = string
  description = "Dashboard template file path. For example, ./templates/defaultDashboard.tpl."
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
  nullable    = false
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags of the resource."
}

variable "template_file_variables" {
  type        = map(string)
  default     = {}
  description = "List of variables values mapping for variables defined in the dashboard template file."
}
