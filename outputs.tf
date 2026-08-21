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
