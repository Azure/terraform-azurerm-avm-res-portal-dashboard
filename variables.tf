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
    condition     = can(regex("^[-a-zA-Z0-9]{3,64}$", var.name))
    error_message = "The dashboard name can only contain alphanumeric characters and hyphens, and must be between 3 and 64 characters long."
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

variable "lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  default     = null
  description = <<DESCRIPTION
(Optional) Controls the Resource Lock configuration for this resource. Omit it, or set it to `null`, to create no lock. The following properties can be specified:

- `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
- `name` - (Optional) The name of the lock. If not specified, a name is generated based on the `kind` value. Changing this forces the creation of a new resource.
DESCRIPTION

  validation {
    condition     = var.lock != null ? contains(["CanNotDelete", "ReadOnly"], var.lock.kind) : true
    error_message = "Lock kind must be either `\"CanNotDelete\"` or `\"ReadOnly\"`."
  }
}

variable "role_assignments" {
  type = map(object({
    name                                   = optional(string, null)
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
(Optional) A map of role assignments to create on the dashboard. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `name` - (Optional) The name of the role assignment. If not set, a random UUID will be generated. Changing this forces the creation of a new resource.
- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
- `principal_id` - The ID of the principal to assign the role to.
- `description` - (Optional) The description of the role assignment.
- `skip_service_principal_aad_check` - (Optional) Retained for compatibility with the legacy `azurerm` schema. It has no effect when using AzAPI.
- `condition` - (Optional) The condition which will be used to scope the role assignment.
- `condition_version` - (Optional) The version of the condition syntax. Leave as `null` if you are not using a condition, if you are then valid values are '2.0'.
- `delegated_managed_identity_resource_id` - (Optional) The delegated Azure Resource Id which contains a Managed Identity. Changing this forces a new resource to be created. This field is only used in cross-tenant scenario.
- `principal_type` - (Optional) The type of the `principal_id`. Possible values are `User`, `Group` and `ServicePrincipal`. It is necessary to explicitly set this attribute when creating role assignments if the principal creating the assignment is constrained by ABAC rules that filters on the PrincipalType attribute.

> Note: There is no built-in RBAC role specific to Azure portal dashboards. Use the generic `Reader`, `Contributor`, or `Owner` roles, or a custom role definition ID.
DESCRIPTION
  nullable    = false

  validation {
    condition = alltrue([
      for ra in var.role_assignments :
      ra.name == null || can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", ra.name))
    ])
    error_message = "Each `role_assignments[*].name`, when supplied, must be a valid lowercase GUID (e.g. 11111111-1111-1111-1111-111111111111)."
  }
}

variable "role_assignment_definition_lookup_enabled" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
(Optional) Whether the `Azure/avm-utl-interfaces/azure` module should resolve role definition names to role definition resource IDs by querying the Azure Authorization API. Set this to `false` when the deployment identity is not permitted to read role definitions, in which case every `role_assignments[*].role_definition_id_or_name` must be supplied as a role definition resource ID.
DESCRIPTION
  nullable    = false
}

variable "resource_types" {
  type = object({
    portal_dashboards = optional(string, "Microsoft.Portal/dashboards@2019-01-01-preview")
  })
  default     = {}
  description = <<DESCRIPTION
(Optional) The AzAPI resource types, including API versions, used by this module.

- `portal_dashboards` - The resource type used for the dashboard itself.

> Note: The default API version is deliberately `2019-01-01-preview`, which models `properties.lenses` as a **map** keyed by lens index (`"lenses": { "0": { ... } }`). API version `2020-09-01-preview` and later model `properties.lenses` as an **array**. If you override this value with a newer API version you must also convert your dashboard template file to the array form, otherwise the deployment will fail.
DESCRIPTION
  nullable    = false
}

variable "ignore_body_changes" {
  type = object({
    portal_dashboards = optional(list(string), [])
  })
  default     = {}
  description = <<DESCRIPTION
(Optional) Paths in each resource's `body` whose changes the `azapi` provider ignores after creation, letting an out-of-band controller own those properties without producing perpetual `terraform plan` drift. Prefer Terraform's `lifecycle.ignore_changes` when the paths are static; use this variable when the paths must be derived from variables or other non-static values.

- `portal_dashboards` - Ignored body paths for the dashboard managed by this module. For example, use `["properties.lenses"]` to let users rearrange dashboard tiles in the Azure portal without Terraform reverting them.

Paths use body-relative dot notation. Individual list indices cannot be targeted; ignore the whole property instead. While a path is ignored, configuration changes at that path are **not** sent to Azure until the path is removed from the list.

Supplying a **non-empty** value requires Terraform 1.11 or later, because `ignore_body_changes` is a write-only argument held in provider-private state; changes take effect only after an `apply`. Leaving the list empty (the default) emits no argument, so the module remains usable on earlier Terraform versions.
DESCRIPTION
  nullable    = false
}

variable "retry" {
  type = object({
    error_message_regex  = optional(list(string), ["ReferencedResourceNotProvisioned"])
    interval_seconds     = optional(number, 10)
    max_interval_seconds = optional(number, 180)
  })
  default     = {}
  description = "(Optional) Retry configuration for the resource operations."
  nullable    = false
}

variable "timeouts" {
  type = object({
    create = optional(string, "30m")
    read   = optional(string, "5m")
    update = optional(string, "30m")
    delete = optional(string, "30m")
  })
  default     = {}
  description = <<DESCRIPTION
(Optional) Timeouts for the resource operations. The following properties can be specified:

- `create` - (Optional) The timeout for creating the resource. Defaults to `30m`.
- `read` - (Optional) The timeout for reading the resource. Defaults to `5m`.
- `update` - (Optional) The timeout for updating the resource. Defaults to `30m`.
- `delete` - (Optional) The timeout for deleting the resource. Defaults to `30m`.
DESCRIPTION
  nullable    = false
}
