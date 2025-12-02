resource "azurerm_key_vault" "this" {
  name                        = "${var.prefix}-kv"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  tenant_id                   = var.tenant_id
  sku_name                    = "standard"
  enabled_for_disk_encryption = true
  purge_protection_enabled    = true

  access_policy {
    tenant_id = var.tenant_id
    object_id = var.principal_id
    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
    ]
  }

  tags = var.tags
}

resource "random_password" "postgres_admin_password" {
  length           = 32
  special          = true
  override_special = "!#$%&*-_=+,.?"
}

resource "azurerm_key_vault_secret" "postgres_password" {
  name         = "postgres-admin-password"
  value        = random_password.postgres_admin_password.result
  key_vault_id = azurerm_key_vault.this.id
}
