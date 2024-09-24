output "dashboard" {
  description = "This is the full output for the resource."
  value       = azurerm_portal_dashboard.dashboard
}

output "resource_id" {
  description = "The ID of the Azure portal dashboard resource."
  value       = azurerm_portal_dashboard.dashboard.id
}
