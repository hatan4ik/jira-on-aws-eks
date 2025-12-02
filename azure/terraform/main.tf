terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.112"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azurerm" {
  features {}
}

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
  tags                = local.tags
}

module "aks" {
  source                     = "./aks"
  resource_group_name        = azurerm_resource_group.this.name
  location                   = var.location
  prefix                     = var.prefix
  dns_prefix                 = "${var.prefix}-aks"
  kubernetes_version         = var.aks_kubernetes_version
  node_count                 = var.aks_node_count
  node_vm_size               = var.aks_node_vm_size
  vnet_subnet_id             = module.network.aks_subnet_id
  enable_oidc_issuer         = var.aks_enable_oidc_issuer
  enable_workload_identity   = var.aks_enable_workload_identity
  tags                       = local.tags
}

module "postgres" {
  source                     = "./postgres"
  resource_group_name        = azurerm_resource_group.this.name
  location                   = var.location
  prefix                     = var.prefix
  delegated_subnet_id        = module.network.db_subnet_id
  vnet_id                    = module.network.vnet_id
  administrator_login        = var.postgres_admin_user
  administrator_password     = var.postgres_admin_password
  sku_name                   = var.postgres_sku_name
  version                    = var.postgres_version
  storage_mb                 = var.postgres_storage_mb
  backup_retention_days      = var.postgres_backup_retention_days
  geo_redundant_backup       = var.postgres_geo_redundant_backup
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
