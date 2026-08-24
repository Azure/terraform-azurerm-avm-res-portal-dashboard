# Complete example

This deploys the module with every input populated, exercising all of the
optional interfaces and controls:

- A dashboard with two tiles, built from a template file that is populated
  through `template_file_variables` (including markdown content read from a
  separate file).
- Tags, including the `hidden-title` key that sets a friendlier display name
  in the Azure portal.
- Role assignments on the dashboard (`Reader` and `Contributor`). There is no
  built-in RBAC role specific to portal dashboards, so the generic roles are
  used.
- A `CanNotDelete` management lock with an explicit name.
- Explicit `resource_types`, `retry`, `timeouts` and `ignore_body_changes`
  values.
