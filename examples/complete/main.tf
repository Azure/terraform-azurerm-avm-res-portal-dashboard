terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.12"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0, < 4.0.0"
    }
  }
}

provider "azapi" {}

locals {
  test_regions = ["eastus", "eastus2", "westus2", "westus3"]
}

data "azapi_client_config" "current" {}

resource "random_integer" "region_index" {
  max = length(local.test_regions) - 1
  min = 0
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.3"
}

resource "azapi_resource" "resource_group" {
  location               = local.test_regions[random_integer.region_index.result]
  name                   = module.naming.resource_group.name_unique
  parent_id              = "/subscriptions/${data.azapi_client_config.current.subscription_id}"
  type                   = "Microsoft.Resources/resourceGroups@2025-04-01"
  response_export_values = []
}

module "this" {
  source = "../.."

  location           = azapi_resource.resource_group.location
  name               = "portal-dashboard-complete"
  parent_id          = azapi_resource.resource_group.id
  template_file_path = "${path.module}/templates/completeDashboard.tpl"
  enable_telemetry   = var.enable_telemetry

  # Values substituted into the dashboard template file. The module always
  # supplies `name`; everything else comes from this map.
  #
  # `markdown_content` is passed through `jsonencode` so the multi-line file
  # contents are escaped into a valid JSON string. The template therefore
  # references it without surrounding quotes.
  template_file_variables = {
    dashboard_title    = "AVM Complete Example"
    dashboard_subtitle = "Deployed by Terraform"
    markdown_content   = jsonencode(file("${path.module}/templates/markdownPart.md"))
    subscription_id    = data.azapi_client_config.current.subscription_id
  }

  # `hidden-title` sets a friendlier display name in the Azure portal than the
  # resource name itself.
  tags = {
    "hidden-title" = "AVM Complete Example Dashboard"
    environment    = "test"
    scenario       = "complete"
  }

  # There is no built-in RBAC role specific to portal dashboards, so the
  # generic roles are used here.
  #
  # `principal_type` is deliberately left unset so Azure resolves it
  # server-side; hardcoding it would make this example fail depending on
  # whether the deploying identity is a user or a service principal.
  role_assignments = {
    reader = {
      role_definition_id_or_name = "Reader"
      principal_id               = coalesce(var.msi_id, data.azapi_client_config.current.object_id)
      description                = "Read-only access to the dashboard."
    }
    contributor = {
      role_definition_id_or_name = "Contributor"
      principal_id               = coalesce(var.msi_id, data.azapi_client_config.current.object_id)
      description                = "Manage the dashboard definition."
    }
  }

  # Set to false when the deployment identity cannot read role definitions and
  # every `role_definition_id_or_name` is supplied as a resource ID instead.
  role_assignment_definition_lookup_enabled = true

  lock = {
    kind = "CanNotDelete"
    name = "lock-complete-example"
  }

  # Pin the AzAPI resource type used by the module. This is the default;
  # override it when targeting a sovereign cloud with older API versions.
  #
  # Note: this must stay on an API version that models `properties.lenses` as a
  # map. `2020-09-01-preview` and later model it as an array and require the
  # template file to be converted.
  portal_dashboard_resource_type = "Microsoft.Portal/dashboards@2019-01-01-preview"

  retry = {
    error_message_regex  = ["ReferencedResourceNotProvisioned"]
    interval_seconds     = 5
    max_interval_seconds = 60
  }

  timeouts = {
    create = "30m"
    read   = "5m"
    update = "30m"
    delete = "30m"
  }

  # Left empty so Terraform continues to manage every body path. Set, for
  # example, `["properties.lenses"]` to let users rearrange tiles in the portal
  # without Terraform reverting them. A non-empty value requires Terraform 1.11+.
  ignore_body_changes = []
}
