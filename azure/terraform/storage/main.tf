resource "azurerm_storage_account" "this" {
  name                     = "st${substr(md5(var.resource_group_name), 0, 22)}"
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
