# Unit tests for the portal dashboard module.
#
# Providers are mocked so these run without touching Azure. They cover input
# validation, the optional lock and role assignment interfaces, and the way the
# dashboard body is assembled from the template file.

mock_provider "azapi" {
  mock_data "azapi_client_config" {
    defaults = {
      subscription_id = "00000000-0000-0000-0000-000000000000"
      tenant_id       = "00000000-0000-0000-0000-000000000001"
      object_id       = "00000000-0000-0000-0000-000000000002"
    }
  }

  # Mocked resources are otherwise given a random `id`, which fails the
  # provider's resource ID validation when used as a `parent_id`.
  mock_resource "azapi_resource" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit-test/providers/Microsoft.Portal/dashboards/unit-test-dashboard"
    }
  }

  # The interfaces module resolves role definition names to resource IDs through
  # this data source; without a mocked response its output is null.
  mock_data "azapi_resource_list" {
    defaults = {
      output = {
        results = [
          {
            id        = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7"
            role_name = "Reader"
          },
          {
            id        = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
            role_name = "Contributor"
          },
        ]
      }
    }
  }
}
mock_provider "modtm" {}
mock_provider "random" {}

variables {
  location           = "eastus"
  name               = "unit-test-dashboard"
  parent_id          = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-unit-test"
  template_file_path = "./tests/unit/templates/dashboard.tpl"
  enable_telemetry   = false
}

# The minimal configuration must create the dashboard and none of the optional
# interface resources.
run "minimal_creates_only_the_dashboard" {
  command = apply

  assert {
    condition     = azapi_resource.this.type == "Microsoft.Portal/dashboards@2019-01-01-preview"
    error_message = "The dashboard must default to the 2019-01-01-preview API version, which models `lenses` as a map."
  }

  assert {
    condition     = azapi_resource.this.parent_id == var.parent_id
    error_message = "The dashboard must be created under the supplied parent_id."
  }

  assert {
    condition     = length(azapi_resource.lock) == 0
    error_message = "No lock should be created when `lock` is null."
  }

  assert {
    condition     = length(azapi_resource.role_assignment) == 0
    error_message = "No role assignments should be created when `role_assignments` is empty."
  }
}

# The template file must be decoded into the request body rather than embedded
# as a JSON string, and `lenses` must survive as a map.
run "template_file_is_decoded_into_body" {
  command = apply

  assert {
    condition     = can(azapi_resource.this.body.properties.lenses)
    error_message = "The rendered template must be decoded into `body.properties`."
  }

  assert {
    condition     = can(azapi_resource.this.body.properties.lenses["0"].parts["0"])
    error_message = "`lenses` must remain a map keyed by lens index for the default API version."
  }
}

# `template_file_variables` must be substituted into the template, and the
# module-supplied `name` variable must be available to it.
run "template_file_variables_are_substituted" {
  command = apply

  variables {
    template_file_path = "./tests/unit/templates/variables.tpl"
    template_file_variables = {
      part_title = "Injected Title"
    }
  }

  assert {
    condition     = azapi_resource.this.body.properties.lenses["0"].parts["0"].metadata.settings.content.settings.title == "Injected Title"
    error_message = "Values from `template_file_variables` must be substituted into the template."
  }

  assert {
    condition     = azapi_resource.this.body.properties.lenses["0"].parts["0"].metadata.settings.content.settings.subtitle == "unit-test-dashboard"
    error_message = "The module must always supply `name` to the template."
  }
}

# `ignore_body_changes` collapses to null when empty so the write-only argument
# is omitted on Terraform versions earlier than 1.11.
run "ignore_body_changes_defaults_to_empty" {
  command = apply

  assert {
    condition     = length(var.ignore_body_changes) == 0
    error_message = "`ignore_body_changes` must default to an empty list."
  }
}

# A lock is created only when requested, and is named by the interfaces module.
run "lock_is_created_when_requested" {
  command = apply

  variables {
    lock = {
      kind = "CanNotDelete"
    }
  }

  assert {
    condition     = length(azapi_resource.lock) == 1
    error_message = "A lock must be created when `lock` is supplied."
  }

  assert {
    condition     = azapi_resource.lock[0].type == "Microsoft.Authorization/locks@2020-05-01"
    error_message = "The lock must use the Microsoft.Authorization/locks resource type."
  }

  assert {
    condition     = azapi_resource.lock[0].body.properties.level == "CanNotDelete"
    error_message = "The lock level must match the requested kind."
  }
}

# Role assignments are created per map entry and scoped to the dashboard.
run "role_assignments_are_scoped_to_the_dashboard" {
  command = apply

  variables {
    role_assignments = {
      reader = {
        role_definition_id_or_name = "Reader"
        principal_id               = "00000000-0000-0000-0000-000000000003"
      }
      contributor = {
        role_definition_id_or_name = "Contributor"
        principal_id               = "00000000-0000-0000-0000-000000000004"
      }
    }
  }

  assert {
    condition     = length(azapi_resource.role_assignment) == 2
    error_message = "One role assignment must be created per entry in `role_assignments`."
  }

  assert {
    condition     = alltrue([for ra in azapi_resource.role_assignment : ra.parent_id == azapi_resource.this.id])
    error_message = "Role assignments must be scoped to the dashboard, not to its resource group."
  }

  assert {
    condition     = azapi_resource.role_assignment["reader"].body.properties.principalId == "00000000-0000-0000-0000-000000000003"
    error_message = "The principal ID must be carried through to the role assignment body."
  }
}

# `name` must be between 3 and 64 characters.
run "name_too_short_is_rejected" {
  command = plan

  variables {
    name = "ab"
  }

  expect_failures = [
    var.name,
  ]
}

run "name_with_invalid_characters_is_rejected" {
  command = plan

  variables {
    name = "invalid_name_with_underscores"
  }

  expect_failures = [
    var.name,
  ]
}

# `parent_id` must be a resource group resource ID.
run "parent_id_must_be_a_resource_group" {
  command = plan

  variables {
    parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
  }

  expect_failures = [
    var.parent_id,
  ]
}

# `lock.kind` is constrained to the two supported values.
run "invalid_lock_kind_is_rejected" {
  command = plan

  variables {
    lock = {
      kind = "ReadWrite"
    }
  }

  expect_failures = [
    var.lock,
  ]
}
