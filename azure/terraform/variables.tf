variable "resource_group_name" {
  description = "Name of the Azure resource group to create or reuse."
  type        = string
  validation {
    condition     = length(var.resource_group_name) > 1 && length(var.resource_group_name) < 90
    error_message = "Resource group name must be between 2 and 89 characters."
  }
}

variable "location" {
  description = "Azure region to deploy resources into."
  type        = string
  default     = "eastus"
  validation {
    condition     = can(regex("^[a-z0-9]+$", var.location))
    error_message = "Location must be a valid Azure region name (e.g., 'eastus', 'westeurope')."
  }
}

variable "prefix" {
  description = "Prefix used for naming Azure resources."
  type        = string
  default     = "jira"
  validation {
    condition     = can(regex("^[a-z0-9]{3,10}$", var.prefix))
    error_message = "Prefix must be 3 to 10 lowercase alphanumeric characters."
  }
}

variable "vnet_cidr" {
  description = "CIDR block for the virtual network."
  type        = string
  default     = "10.20.0.0/16"
  validation {
    condition     = can(cidrnetmask(var.vnet_cidr))
    error_message = "The vnet_cidr must be a valid CIDR block (e.g., '10.20.0.0/16')."
  }
}

variable "aks_subnet_cidr" {
  description = "CIDR for the AKS subnet."
  type        = string
  default     = "10.20.1.0/24"
  validation {
    condition     = can(cidrnetmask(var.aks_subnet_cidr))
    error_message = "The aks_subnet_cidr must be a valid CIDR block (e.g., '10.20.1.0/24')."
  }
}

variable "db_subnet_cidr" {
  description = "CIDR for the PostgreSQL delegated subnet."
  type        = string
  default     = "10.20.2.0/24"
  validation {
    condition     = can(cidrnetmask(var.db_subnet_cidr))
    error_message = "The db_subnet_cidr must be a valid CIDR block (e.g., '10.20.2.0/24')."
  }
}

variable "appgw_subnet_cidr" {
  description = "CIDR for the Application Gateway subnet."
  type        = string
  default     = "10.20.3.0/24"
  validation {
    condition     = can(cidrnetmask(var.appgw_subnet_cidr))
    error_message = "The appgw_subnet_cidr must be a valid CIDR block (e.g., '10.20.3.0/24')."
  }
}

variable "admin_ip_address" {
  description = "Admin IP address for management access (CIDR format)."
  type        = string

  validation {
    condition     = can(cidrhost(var.admin_ip_address, 0))
    error_message = "Admin IP address must be a valid CIDR block (e.g., 203.0.113.1/32)."
  }
}

variable "aks_kubernetes_version" {
  description = "Kubernetes version for the AKS cluster."
  type        = string
  default     = "1.30.3"

  validation {
    condition     = can(regex("^1\\.(2[89]|3[0-9])\\.[0-9]+$", var.aks_kubernetes_version))
    error_message = "Kubernetes version must be 1.28.x or higher."
  }
}

variable "aks_node_vm_size" {
  description = "VM size for AKS system nodes."
  type        = string
  default     = "Standard_D4s_v5"
  validation {
    condition     = startswith(var.aks_node_vm_size, "Standard_")
    error_message = "VM size should be a 'Standard_' SKU."
  }
}

variable "aks_system_node_pool_min_count" {
  description = "Minimum node count for the system node pool."
  type        = number
  default     = 1
}

variable "aks_system_node_pool_max_count" {
  description = "Maximum node count for the system node pool."
  type        = number
  default     = 3
}

variable "aks_user_node_pool_vm_size" {
  description = "VM size for the user node pool."
  type        = string
  default     = "Standard_D8s_v5"
  validation {
    condition     = startswith(var.aks_user_node_pool_vm_size, "Standard_")
    error_message = "VM size should be a 'Standard_' SKU."
  }
}

variable "aks_user_node_pool_min_count" {
  description = "Minimum node count for the user node pool."
  type        = number
  default     = 2
}

variable "aks_user_node_pool_max_count" {
  description = "Maximum node count for the user node pool."
  type        = number
  default     = 5
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
  default     = "15"

  validation {
    condition     = contains(["13", "14", "15", "16"], var.postgres_version)
    error_message = "PostgreSQL version must be 13, 14, 15, or 16."
  }
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
  validation {
    condition     = var.postgres_storage_mb >= 32768
    error_message = "PostgreSQL storage must be at least 32768 MB (32 GB)."
  }
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
  description = "Initial admin password for PostgreSQL, used to set the secret in Azure Key Vault."
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{12,}$", var.postgres_admin_password))
    error_message = "Password must be at least 12 characters with uppercase, lowercase, number, and special character."
  }
}

variable "postgres_database_name" {
  description = "Name for the PostgreSQL database."
  type        = string
  default     = "jira"
}

variable "storage_account_replication_type" {
  description = "Replication type for the storage account (LRS, ZRS)."
  type        = string
  default     = "ZRS"
  validation {
    condition     = contains(["LRS", "ZRS"], var.storage_account_replication_type)
    error_message = "Storage replication type must be either 'LRS' or 'ZRS'."
  }
}

variable "file_share_quota_gb" {
  description = "Quota for the Jira shared home Azure Files share."
  type        = number
  default     = 512
}
