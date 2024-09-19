# avm-res-portal-dashboard

This module provides a generic way to create and manage an Azure portal dashboard resource. To use this module in your Terraform configuration, you'll need to provide values for the required variables.

## Features

This is the Azure Portal Dashboard for the Azure Verified Modules library.  This module deploys the Azure portal dashboard by using json template files for dashboard definitions.  It leverages the AzureRM provider and sets a number of initial defaults to minimize the overall inputs for simple configurations.

## Example Usage

Here is an example of how you can use this module in your Terraform configuration:

```terraform
module "portal_dashboard" {
  source                  = "Azure/avm-res-portal-dashboard/azurerm"
  location                = azurerm_resource_group.this.location
  name                    = "portal-dashboard"
  resource_group_name     = azurerm_resource_group.this.name
  template_file_path      = "../templates/defaultDashboard.tpl"
  template_file_variables = {}
  enable_telemetry        = var.enable_telemetry # see variables.tf
}
```

