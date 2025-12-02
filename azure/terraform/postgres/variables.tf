variable "resource_group_name" {
  description = "Resource group for PostgreSQL resources."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "prefix" {
  description = "Resource name prefix."
  type        = string
}

variable "delegated_subnet_id" {
  description = "Delegated subnet ID for PostgreSQL Flexible Server."
  type        = string
}

variable "vnet_id" {
  description = "Virtual network ID for DNS linking."
  type        = string
}

variable "administrator_login" {
  description = "Admin username for PostgreSQL."
  type        = string
}

variable "administrator_password" {
  description = "Admin password for PostgreSQL."
  type        = string
  sensitive   = true
}

variable "sku_name" {
  description = "SKU for PostgreSQL Flexible Server."
  type        = string
}

variable "version" {
  description = "PostgreSQL version."
  type        = string
}

variable "storage_mb" {
  description = "Storage in MB."
  type        = number
}

variable "backup_retention_days" {
  description = "Backup retention window."
  type        = number
}

variable "geo_redundant_backup" {
  description = "Enable geo-redundant backups."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply."
  type        = map(string)
  default     = {}
}
