output "name" {
  description = "The name of the portal dashboard."
  value       = azapi_resource.this.name
}

output "resource" {
  description = "The full portal dashboard azapi_resource."
  sensitive   = true
  value       = azapi_resource.this
}

output "resource_id" {
  description = "The ID of the portal dashboard."
  value       = azapi_resource.this.id
}

output "role_assignments" {
  description = "Map of role assignments created on the dashboard, keyed by the `var.role_assignments` map key."
  value       = module.role_assignments.role_assignments
}
