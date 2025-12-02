output "account_name" {
  value       = azurerm_storage_account.this.name
  description = "Storage account name."
}

output "share_name" {
  value       = azurerm_storage_share.jira.name
  description = "Azure Files share name."
}

output "storage_account_id" {
  value       = azurerm_storage_account.this.id
  description = "Storage account resource ID."
}
