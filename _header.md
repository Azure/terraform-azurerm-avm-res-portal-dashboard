# avm-res-portal-dashboard

This module provides a generic way to create and manage an Azure portal dashboard resource. To use this module in your Terraform configuration, you'll need to provide values for the required variables.

## Features

This is the Azure Portal Dashboard for the Azure Verified Modules library.  This module deploys the Azure portal dashboard by using json template files for dashboard definitions.  It leverages the AzAPI provider and sets a number of initial defaults to minimize the overall inputs for simple configurations.

The module implements the following AVM interfaces:

- `role_assignments` - RBAC role assignments scoped to the dashboard.
- `lock` - an optional `CanNotDelete` or `ReadOnly` management lock.
- `tags` - resource tags. Use the `hidden-title` tag key to set a friendlier display title for the dashboard.

> [!NOTE]
> There is no built-in Azure RBAC role specific to portal dashboards. Use the generic `Reader`, `Contributor`, or `Owner` roles, or supply a custom role definition resource ID.

### Dashboard template API version

The `portal_dashboard_resource_type` default is `Microsoft.Portal/dashboards@2019-01-01-preview`, which models `properties.lenses` as a **map** keyed by lens index:

```json
{ "lenses": { "0": { "order": 0, "parts": { "0": { } } } } }
```

API version `2020-09-01-preview` and later model `lenses` and `parts` as **arrays** instead. If you override `portal_dashboard_resource_type` with a newer API version you must also convert your dashboard template file to the array form, otherwise the deployment will fail.

## Upgrading from a version that used the AzureRM provider

Earlier releases of this module managed the dashboard with `azurerm_portal_dashboard`, and took the parent resource group as `resource_group_name`. This release replaces the resource with `azapi_resource` and takes `parent_id` (the resource group's resource ID) instead, matching the AzAPI-native convention used by other migrated AVM modules.

Update the module call:

```diff
- resource_group_name = azurerm_resource_group.this.name
+ parent_id           = azurerm_resource_group.this.id
```

Existing state must also be migrated. A Terraform `moved` block cannot be used: the `azapi` provider's move support derives the API version from its own embedded schema and selects `Microsoft.Portal/dashboards@2026-04-01`, which Azure Resource Manager does not currently serve — the newest version ARM accepts is `2025-04-01-preview`. The post-move refresh therefore fails with `NoRegisteredProviderFound`. See [Azure/terraform-provider-azapi#1216](https://github.com/Azure/terraform-provider-azapi/issues/1216).

Migrate the state manually instead, substituting your own module address and dashboard resource ID:

```shell
terraform state rm 'module.<name>.azurerm_portal_dashboard.dashboard'

terraform import 'module.<name>.azapi_resource.this' \
  '/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Portal/dashboards/<dashboard>?api-version=2019-01-01-preview'
```

The `?api-version=` suffix is required; it pins the imported resource to the same API version the module uses by default. After importing, `terraform plan` reports no destructive changes — the dashboard is updated in place and any newly configured `role_assignments` and `lock` resources are added.

## Example Usage

Here is an example of how you can use this module in your Terraform configuration:

```terraform
module "portal_dashboard" {
  source                  = "Azure/avm-res-portal-dashboard/azurerm"
  location                = azapi_resource.rg.location
  name                    = "portal-dashboard"
  parent_id               = azapi_resource.rg.id
  template_file_path      = "../templates/defaultDashboard.tpl"
  template_file_variables = {}
  enable_telemetry        = var.enable_telemetry # see variables.tf

  role_assignments = {
    reader = {
      role_definition_id_or_name = "Reader"
      principal_id               = data.azapi_client_config.this.object_id
    }
  }

  lock = {
    kind = "CanNotDelete"
  }
}
```


