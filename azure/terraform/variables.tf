variable "resource_group_name" {
  description = "Name of the Azure resource group to create or reuse."
  type        = string
}

variable "location" {
  description = "Azure region to deploy resources into."
  type        = string
  default     = "eastus"
}

variable "prefix" {
  description = "Prefix used for naming Azure resources."
  type        = string
  default     = "jira"
}

variable "vnet_cidr" {
  description = "CIDR block for the virtual network."
  type        = string
  default     = "10.20.0.0/16"
}

variable "aks_subnet_cidr" {
  description = "CIDR for the AKS subnet."
  type        = string
  default     = "10.20.1.0/24"
}

variable "db_subnet_cidr" {
  description = "CIDR for the PostgreSQL delegated subnet."
  type        = string
  default     = "10.20.2.0/24"
}

variable "appgw_subnet_cidr" {
  description = "CIDR for the Application Gateway subnet."
  type        = string
  default     = "10.20.3.0/24"
}

variable "aks_kubernetes_version" {
  description = "Kubernetes version for the AKS cluster."
  type        = string
  default     = "1.29.7"
}

variable "aks_node_count" {
  description = "Node count for the system node pool."
  type        = number
  default     = 3
}

variable "aks_node_vm_size" {
  description = "VM size for AKS nodes."
  type        = string
  default     = "Standard_D4s_v5"
}

variable "aks_enable_oidc_issuer" {
  description = "Enable OIDC issuer for AKS (required for workload identity)."
  type        = bool
  default     = true
}

variable "aks_enable_workload_identity" {
  description = "Enable workload identity for AKS to replace kubelet-managed service account signing."
  type        = bool
  default     = true
}

variable "postgres_version" {
  description = "PostgreSQL engine major version."
  type        = string
  default     = "14"
}

variable "postgres_sku_name" {
  description = "SKU for PostgreSQL Flexible Server."
  type        = string
  default     = "GP_Standard_D4s_v3"
}

variable "postgres_storage_mb" {
  description = "Allocated storage for PostgreSQL in MB."
  type        = number
  default     = 65536
}

variable "postgres_backup_retention_days" {
  description = "Backup retention window for PostgreSQL."
  type        = number
  default     = 14
}

variable "postgres_geo_redundant_backup" {
  description = "Enable geo-redundant backups."
  type        = bool
  default     = true
}

variable "postgres_admin_user" {
  description = "Admin username for PostgreSQL."
  type        = string
  default     = "jira_admin"
}

variable "postgres_admin_password" {
  description = "Admin password for PostgreSQL."
  type        = string
  sensitive   = true
}

variable "storage_account_replication_type" {
  description = "Replication type for the storage account (LRS, ZRS)."
  type        = string
  default     = "ZRS"
}

variable "file_share_quota_gb" {
  description = "Quota for the Jira shared home Azure Files share."
  type        = number
  default     = 512
}
