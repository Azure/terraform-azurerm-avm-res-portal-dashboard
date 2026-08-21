output "name" {
  description = "The name of the portal dashboard."
  value       = module.this.name
}

output "resource_id" {
  description = "The ID of the portal dashboard."
  value       = module.this.resource_id
}

output "role_assignments" {
  description = "The role assignments created on the portal dashboard."
  value       = module.this.role_assignments
}
