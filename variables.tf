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

variable "parent_id" {
  type        = string
  description = "The Azure resource ID of the parent resource group, in the form `/subscriptions/{subscription_id}/resourceGroups/{resource_group_name}`."
  nullable    = false

  validation {
    condition     = can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+$", var.parent_id))
    error_message = "`parent_id` must be a valid resource group resource ID, in the form `/subscriptions/{subscription_id}/resourceGroups/{resource_group_name}`."
  }
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
    name = optional(string, null)
    kind = string
  })
  default     = null
  description = <<DESCRIPTION
Controls the management lock applied to the portal dashboard. Defaults to `null` (no lock).

- `kind` - (Required) The kind of lock to apply. Possible values are `CanNotDelete` and `ReadOnly`.
- `name` - (Optional) The name of the lock. If not specified, a name will be generated.
DESCRIPTION

  validation {
    condition     = var.lock != null ? contains(["CanNotDelete", "ReadOnly"], var.lock.kind) : true
    error_message = "Lock kind must be either `\"CanNotDelete\"` or `\"ReadOnly\"`."
  }
}

variable "role_assignments" {
  type = map(object({
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
A map of role assignments to create on the resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time. Defaults to `{}`.

- `role_definition_id_or_name` - (Required) The ID or name of the role definition to assign to the principal.
- `principal_id` - (Required) The ID of the principal to assign the role to.
- `description` - (Optional) The description of the role assignment. Defaults to `null`.
- `skip_service_principal_aad_check` - (Optional) Retained for backwards compatibility with the legacy `azurerm` schema. Not honoured under AzAPI: the field is accepted but has no effect on the underlying role assignment. Defaults to `false`.
- `condition` - (Optional) The condition which will be used to scope the role assignment. Defaults to `null`.
- `condition_version` - (Optional) The version of the condition syntax. Valid value is `2.0`. Defaults to `null`.
- `delegated_managed_identity_resource_id` - (Optional) The resource ID of the delegated managed identity. Defaults to `null`.
- `principal_type` - (Optional) The type of principal. One of `User`, `Group`, `ServicePrincipal`, `ForeignGroup`, `Device`. Defaults to `null`.

> Note: There is no built-in Azure RBAC role specific to portal dashboards. Use the generic `Reader`, `Contributor` or `Owner` roles, or supply a custom role definition resource ID.
DESCRIPTION
  nullable    = false
}

variable "role_assignment_definition_lookup_enabled" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
Whether the `Azure/avm-utl-interfaces/azure` module composed by the internal `role_assignments` submodule should resolve role definition names supplied via `role_definition_id_or_name` by querying the Azure Authorization API. Defaults to `true`.

Set to `false` if you only ever supply fully-qualified role definition resource IDs (`/subscriptions/.../providers/Microsoft.Authorization/roleDefinitions/<guid>`) in `role_definition_id_or_name`. Disabling the lookup avoids the API call, which is useful in air-gapped or permission-restricted environments where the calling identity lacks `Microsoft.Authorization/roleDefinitions/read` at the parent scope.
DESCRIPTION
  nullable    = false
}

variable "portal_dashboard_resource_type" {
  type        = string
  default     = "Microsoft.Portal/dashboards@2019-01-01-preview"
  description = <<DESCRIPTION
The resource type, including API version, used for the portal dashboard. Defaults to `Microsoft.Portal/dashboards@2019-01-01-preview`.

> Note: this deliberately defaults to `2019-01-01-preview`, which models `properties.lenses` as a **map** keyed by lens index (`"lenses": { "0": { ... } }`). API version `2020-09-01-preview` and later model `properties.lenses` as an **array**. If you override this value with a newer API version you must also convert your dashboard template file to the array form, otherwise the deployment will fail.
DESCRIPTION
  nullable    = false
}

variable "ignore_body_changes" {
  type        = list(string)
  default     = []
  description = <<DESCRIPTION
Paths in the dashboard's `body` whose changes the `azapi` provider ignores after creation, letting an out-of-band controller own those properties without producing perpetual `terraform plan` drift. Defaults to `[]`. Prefer Terraform's `lifecycle.ignore_changes` when the paths are static; use this variable when the paths must be derived from variables or other non-static values.

For example, use `["properties.lenses"]` to let users rearrange dashboard tiles in the Azure portal without Terraform reverting them.

Paths use body-relative dot notation. Individual list indices cannot be targeted; ignore the whole property instead. While a path is ignored, configuration changes at that path are **not** sent to Azure until the path is removed from the list.

Supplying a **non-empty** value requires Terraform 1.11 or later, because `ignore_body_changes` is a write-only argument held in provider-private state; changes take effect only after an `apply`. Leaving the list empty (the default) emits no argument, so the module remains usable on earlier Terraform versions.
DESCRIPTION
  nullable    = false
}

variable "retry" {
  type = object({
    error_message_regex  = optional(list(string))
    interval_seconds     = optional(number)
    max_interval_seconds = optional(number)
  })
  default     = null
  description = <<DESCRIPTION
Retry configuration applied to every `azapi` resource managed by the module (the dashboard, its lock, and role assignments). Defaults to `null` (no custom retry).

- `error_message_regex`  - (Optional) A list of regex patterns matching error messages that trigger a retry. Defaults to `null`.
- `interval_seconds`     - (Optional) Initial interval between retries in seconds. Defaults to `null` (provider default).
- `max_interval_seconds` - (Optional) Maximum interval between retries in seconds. Defaults to `null` (provider default).

See <https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource#retry> for full semantics.
DESCRIPTION
}

variable "timeouts" {
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default     = null
  description = <<DESCRIPTION
Default per-operation timeouts applied to every `azapi` resource managed by the module. Defaults to `null` (provider defaults). Each value is a Go duration string (e.g. `30m`, `1h`).

- `create` - (Optional) Timeout for create operations. Defaults to `null`.
- `read` - (Optional) Timeout for read operations. Defaults to `null`.
- `update` - (Optional) Timeout for update operations. Defaults to `null`.
- `delete` - (Optional) Timeout for delete operations. Defaults to `null`.
DESCRIPTION
}
