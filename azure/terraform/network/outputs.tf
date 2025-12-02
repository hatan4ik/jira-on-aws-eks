output "vnet_id" {
  value       = azurerm_virtual_network.this.id
  description = "Virtual network ID."
}

output "aks_subnet_id" {
  value       = azurerm_subnet.aks.id
  description = "AKS subnet ID."
}

output "db_subnet_id" {
  value       = azurerm_subnet.db.id
  description = "PostgreSQL delegated subnet ID."
}

output "appgw_subnet_id" {
  value       = azurerm_subnet.appgw.id
  description = "Application Gateway subnet ID."
}
