<!-- BEGIN_TF_DOCS -->
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

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.9, < 2.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 3.110)

- <a name="requirement_modtm"></a> [modtm](#requirement\_modtm) (~> 0.3)

- <a name="requirement_random"></a> [random](#requirement\_random) (~> 3.5)

## Resources

The following resources are used by this module:

- [azurerm_portal_dashboard.dashboard](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/portal_dashboard) (resource)
- [modtm_telemetry.telemetry](https://registry.terraform.io/providers/azure/modtm/latest/docs/resources/telemetry) (resource)
- [random_uuid.telemetry](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) (resource)
- [azurerm_client_config.telemetry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)
- [modtm_module_source.telemetry](https://registry.terraform.io/providers/azure/modtm/latest/docs/data-sources/module_source) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_location"></a> [location](#input\_location)

Description: Azure region where the resource should be deployed.

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: The name of the dashboard.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The resource group where the resources will be deployed.

Type: `string`

### <a name="input_template_file_path"></a> [template\_file\_path](#input\_template\_file\_path)

Description: Dashboard template file path. For example, ./templates/defaultDashboard.tpl.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see <https://aka.ms/avm/telemetryinfo>.  
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: (Optional) Tags of the resource.

Type: `map(string)`

Default: `null`

### <a name="input_template_file_variables"></a> [template\_file\_variables](#input\_template\_file\_variables)

Description: List of variables values mapping for variables defined in the dashboard template file.

Type: `map(string)`

Default: `{}`

## Outputs

The following outputs are exported:

### <a name="output_dashboard"></a> [dashboard](#output\_dashboard)

Description: This is the full output for the resource.

### <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id)

Description: The ID of the Azure portal dashboard resource.

## Modules

No modules.

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->