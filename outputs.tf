output "name" {
  description = "The name of the portal dashboard."
  value       = azapi_resource.this.name
}

output "resource_id" {
  description = "The ID of the portal dashboard."
  value       = azapi_resource.this.id
}
