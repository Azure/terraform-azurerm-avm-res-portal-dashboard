terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.12"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azapi" {}


## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group.
module "regions" {
  source  = "Azure/avm-utl-regions/azurerm"
  version = "~> 0.1"
}

# This allows us to randomize the region for the resource group.
resource "random_integer" "region_index" {
  max = length(module.regions.regions) - 1
  min = 0
}
## End of section to provide a random Azure region for the resource group

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.3"
}

data "azapi_client_config" "this" {}

# This is required for resource modules
resource "azapi_resource" "rg" {
  location  = module.regions.regions[random_integer.region_index.result].name
  name      = module.naming.resource_group.name_unique
  parent_id = "/subscriptions/${data.azapi_client_config.this.subscription_id}"
  type      = "Microsoft.Resources/resourceGroups@2024-11-01"
}

# This is the module call
# Do not specify location here due to the randomization above.
# Leaving location as `null` will cause the module to use the resource group location
# with a data source.
module "test" {
  source = "../../"

  # source             = "Azure/avm-res-portal-dashboard/azurerm"
  # ...
  location                = azapi_resource.rg.location
  name                    = "portal-dashboard"
  resource_group_name     = azapi_resource.rg.name
  template_file_path      = "./templates/defaultDashboard.tpl"
  enable_telemetry        = var.enable_telemetry # see variables.tf
  template_file_variables = {}

  role_assignments = {
    reader = {
      role_definition_id_or_name = "Reader"
      principal_id               = data.azapi_client_config.this.object_id
    }
  }
}
