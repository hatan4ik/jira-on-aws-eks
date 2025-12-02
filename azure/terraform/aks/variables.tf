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

variable "node_count" {
  description = "Default node count."
  type        = number
}

variable "node_vm_size" {
  description = "VM size for AKS nodes."
  type        = string
}

variable "vnet_subnet_id" {
  description = "Subnet ID for AKS node pool."
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
