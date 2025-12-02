resource "random_string" "suffix" {
  length  = 6
  upper   = false
  numeric = true
  special = false
}

resource "azurerm_storage_account" "this" {
  name                     = substr("${var.prefix}file${random_string.suffix.result}", 0, 24)
  location                 = var.location
  resource_group_name      = var.resource_group_name
  account_kind             = "FileStorage"
  account_tier             = "Premium"
  account_replication_type = var.replication_type
  enable_https_traffic_only = true
  tags                      = var.tags
}

resource "azurerm_storage_share" "jira" {
  name                 = "jira-shared-home"
  storage_account_name = azurerm_storage_account.this.name
  quota                = var.file_share_quota_gb
}
