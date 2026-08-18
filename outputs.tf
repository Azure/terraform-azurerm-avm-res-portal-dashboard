output "dashboard" {
  description = "This is the full output for the resource."
  value       = azapi_resource.this
}

output "name" {
  description = "The name of the Azure portal dashboard resource."
  value       = azapi_resource.this.name
}

output "resource" {
  description = "This is the full output for the resource."
  value       = azapi_resource.this
}

output "resource_id" {
  description = "The ID of the Azure portal dashboard resource."
  value       = azapi_resource.this.id
}
