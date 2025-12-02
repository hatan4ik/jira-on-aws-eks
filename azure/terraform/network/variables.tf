variable "resource_group_name" {
  description = "Resource group for network resources."
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

variable "vnet_cidr" {
  description = "Virtual network CIDR."
  type        = string
}

variable "aks_subnet_cidr" {
  description = "AKS subnet CIDR."
  type        = string
}

variable "db_subnet_cidr" {
  description = "Database subnet CIDR."
  type        = string
}

variable "appgw_subnet_cidr" {
  description = "Application Gateway subnet CIDR."
  type        = string
}

variable "admin_ip_address" {
  description = "Admin IP address for SSH access to AKS nodes."
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
  default     = {}
}