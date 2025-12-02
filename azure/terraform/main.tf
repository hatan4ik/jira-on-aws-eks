terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.112"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

locals {
  tags = {
    project = "jira"
    env     = "prod"
  }
}

resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.tags
}

module "network" {
  source              = "./network"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  prefix              = var.prefix
  vnet_cidr           = var.vnet_cidr
  aks_subnet_cidr     = var.aks_subnet_cidr
  db_subnet_cidr      = var.db_subnet_cidr
  appgw_subnet_cidr   = var.appgw_subnet_cidr
  admin_ip_address    = var.admin_ip_address
  tags                = local.tags
}

module "monitoring" {
  source              = "./monitoring"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  prefix              = var.prefix
  tags                = local.tags
}

module "keyvault" {
  source                  = "./keyvault"
  resource_group_name     = azurerm_resource_group.this.name
  location                = var.location
  prefix                  = var.prefix
  tenant_id               = data.azurerm_client_config.current.tenant_id
  principal_id            = data.azurerm_client_config.current.object_id
  postgres_admin_password = var.postgres_admin_password
  tags                    = local.tags
}

data "azurerm_key_vault_secret" "postgres_password" {
  name         = "postgres-admin-password"
  key_vault_id = module.keyvault.key_vault_id
}

module "aks" {
  source                       = "./aks"
  resource_group_name          = azurerm_resource_group.this.name
  location                     = var.location
  prefix                       = var.prefix
  dns_prefix                   = "${var.prefix}-aks"
  kubernetes_version           = var.aks_kubernetes_version
  node_vm_size                 = var.aks_node_vm_size
  system_node_pool_min_count   = var.aks_system_node_pool_min_count
  system_node_pool_max_count   = var.aks_system_node_pool_max_count
  user_node_pool_vm_size       = var.aks_user_node_pool_vm_size
  user_node_pool_min_count     = var.aks_user_node_pool_min_count
  user_node_pool_max_count     = var.aks_user_node_pool_max_count
  vnet_subnet_id               = module.network.aks_subnet_id
  log_analytics_workspace_id   = module.monitoring.log_analytics_workspace_id
  enable_oidc_issuer           = var.aks_enable_oidc_issuer
  enable_workload_identity     = var.aks_enable_workload_identity
  tags                         = local.tags
}

module "postgres" {
  source                     = "./postgres"
  resource_group_name        = azurerm_resource_group.this.name
  location                   = var.location
  prefix                     = var.prefix
  delegated_subnet_id        = module.network.db_subnet_id
  vnet_id                    = module.network.vnet_id
  administrator_login        = var.postgres_admin_user
  administrator_password     = data.azurerm_key_vault_secret.postgres_password.value
  sku_name                   = var.postgres_sku_name
  version                    = var.postgres_version
  storage_mb                 = var.postgres_storage_mb
  backup_retention_days      = var.postgres_backup_retention_days
  geo_redundant_backup       = var.postgres_geo_redundant_backup
  database_name              = var.postgres_database_name
  tags                       = local.tags
}

module "storage" {
  source              = "./storage"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  prefix              = var.prefix
  replication_type    = var.storage_account_replication_type
  file_share_quota_gb = var.file_share_quota_gb
  tags                = local.tags
}
