resource "azurerm_private_dns_zone" "postgres" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  name                  = "${var.prefix}-postgres-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.postgres.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false
}

resource "azurerm_postgresql_flexible_server" "this" {
  name                   = "${var.prefix}-pg"
  resource_group_name    = var.resource_group_name
  location               = var.location
  version                = var.version
  delegated_subnet_id    = var.delegated_subnet_id
  private_dns_zone_id    = azurerm_private_dns_zone.postgres.id
  administrator_login    = var.administrator_login
  administrator_password = var.administrator_password
  storage_mb             = var.storage_mb
  backup_retention_days  = var.backup_retention_days
  sku_name               = var.sku_name
  zone                   = var.availability_zone
  tags                   = var.tags

  geo_redundant_backup_enabled = var.geo_redundant_backup
  public_network_access_enabled = false

  high_availability {
    mode = "ZoneRedundant"
  }
}

resource "azurerm_postgresql_flexible_database" "jira" {
  name      = var.database_name
  server_id = azurerm_postgresql_flexible_server.this.id
  collation = "en_US.UTF8"
  charset   = "UTF8"
}
