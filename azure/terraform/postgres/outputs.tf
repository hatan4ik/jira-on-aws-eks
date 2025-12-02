output "fqdn" {
  value       = azurerm_postgresql_flexible_server.this.fqdn
  description = "PostgreSQL Flexible Server FQDN."
}

output "id" {
  value       = azurerm_postgresql_flexible_server.this.id
  description = "PostgreSQL server ID."
}

output "database_name" {
  value       = azurerm_postgresql_flexible_database.jira.name
  description = "Jira database name."
}
