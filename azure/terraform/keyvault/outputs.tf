output "key_vault_id" {
  value       = azurerm_key_vault.this.id
  description = "The ID of the Key Vault."
}

output "postgres_password_secret_id" {
  value       = azurerm_key_vault_secret.postgres_password.id
  description = "The ID of the PostgreSQL admin password secret."
}
