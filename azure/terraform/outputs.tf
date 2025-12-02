output "app_gateway_name" {
  description = "The name of the Application Gateway."
  value       = module.appgw.name
}

output "agic_identity_client_id" {
  description = "The client ID of the User Assigned Identity for AGIC."
  value       = module.appgw.agic_identity_client_id
}