resource "azurerm_storage_account" "this" {
  name                     = "st${substr(md5(var.resource_group_name), 0, 22)}"
  location                 = var.location
  resource_group_name      = var.resource_group_name
  account_kind             = "FileStorage"
  account_tier             = "Premium"
  account_replication_type = var.replication_type
  enable_https_traffic_only = true
  
  # Disable public access and rely on the private endpoint
  public_network_access_enabled = false

  tags = var.tags
}

resource "azurerm_storage_share" "jira" {
  name                 = "jira-shared-home"
  storage_account_name = azurerm_storage_account.this.name
  quota                = var.file_share_quota_gb
  enabled_protocol     = "NFS"
}

# --- Private Endpoint and DNS ---

resource "azurerm_private_dns_zone" "file" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "file" {
  name                  = "${var.prefix}-file-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.file.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false
}

resource "azurerm_private_endpoint" "file" {
  name                = "${var.prefix}-storage-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.aks_subnet_id
  tags                = var.tags

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.file.id]
  }

  private_service_connection {
    name                           = "${var.prefix}-storage-psc"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.this.id
    subresource_names              = ["file"]
  }
}
