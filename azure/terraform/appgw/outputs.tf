output "name" {
  description = "The name of the Application Gateway."
  value       = azurerm_application_gateway.this.name
}

output "id" {
  description = "The ID of the Application Gateway."
  value       = azurerm_application_gateway.this.id
}

output "agic_identity_client_id" {
  description = "The client ID of the User Assigned Identity for AGIC."
  value       = azurerm_user_assigned_identity.agic.client_id
}
