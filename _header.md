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

The `resource_types.portal_dashboards` default is `Microsoft.Portal/dashboards@2019-01-01-preview`, which models `properties.lenses` as a **map** keyed by lens index:

```json
{ "lenses": { "0": { "order": 0, "parts": { "0": { } } } } }
```

API version `2020-09-01-preview` and later model `lenses` and `parts` as **arrays** instead. If you override `resource_types.portal_dashboards` with a newer API version you must also convert your dashboard template file to the array form, otherwise the deployment will fail.

## Example Usage

Here is an example of how you can use this module in your Terraform configuration:

```terraform
module "portal_dashboard" {
  source                  = "Azure/avm-res-portal-dashboard/azurerm"
  location                = azapi_resource.rg.location
  name                    = "portal-dashboard"
  resource_group_name     = azapi_resource.rg.name
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


