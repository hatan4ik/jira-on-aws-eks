variable "resource_group_name" {
  description = "Resource group for AKS."
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

variable "dns_prefix" {
  description = "DNS prefix for AKS."
  type        = string
}

variable "kubernetes_version" {
  description = "AKS Kubernetes version."
  type        = string
}

variable "node_vm_size" {
  description = "VM size for AKS nodes."
  type        = string
}

variable "system_node_pool_min_count" {
  description = "Minimum node count for the system node pool."
  type        = number
  default     = 1
}

variable "system_node_pool_max_count" {
  description = "Maximum node count for the system node pool."
  type        = number
  default     = 3
}

variable "user_node_pool_vm_size" {
  description = "VM size for the user node pool."
  type        = string
  default     = "Standard_D4s_v5"
}

variable "user_node_pool_min_count" {
  description = "Minimum node count for the user node pool."
  type        = number
  default     = 2
}

variable "user_node_pool_max_count" {
  description = "Maximum node count for the user node pool."
  type        = number
  default     = 5
}

variable "vnet_subnet_id" {
  description = "Subnet ID for AKS node pool."
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace."
  type        = string
}

variable "enable_oidc_issuer" {
  description = "Enable OIDC issuer."
  type        = bool
  default     = true
}

variable "enable_workload_identity" {
  description = "Enable workload identity."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply."
  type        = map(string)
  default     = {}
}
