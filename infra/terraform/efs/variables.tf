variable "project_name" {
  description = "Project name prefix"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for EFS mount targets"
  type        = list(string)
}

variable "vpc_cidr" {
  description = "VPC CIDR for default ingress restrictions"
  type        = string
}

variable "allowed_cidr_blocks" {
  description = "Optional override for NFS ingress CIDRs"
  type        = list(string)
  default     = []
}
