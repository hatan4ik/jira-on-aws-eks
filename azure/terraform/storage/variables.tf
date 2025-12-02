variable "resource_group_name" {
  description = "Resource group for storage."
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

variable "replication_type" {
  description = "Storage account replication (LRS, ZRS)."
  type        = string
  default     = "ZRS"
}

variable "file_share_quota_gb" {
  description = "Quota for the Azure Files share in GB."
  type        = number
  default     = 512
}

variable "tags" {
  description = "Tags to apply."
  type        = map(string)
  default     = {}
}
