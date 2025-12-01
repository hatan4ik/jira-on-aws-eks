variable "project_name" {
  description = "Project name prefix"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for DB subnet group"
  type        = list(string)
}

variable "vpc_cidr" {
  description = "VPC CIDR for default ingress restrictions"
  type        = string
}

variable "allowed_cidr_blocks" {
  description = "Optional override for DB ingress CIDRs"
  type        = list(string)
  default     = []
}

variable "db_name" {
  description = "Jira database name"
  type        = string
}

variable "username" {
  description = "Jira database username"
  type        = string
}

variable "password" {
  description = "Jira database password"
  type        = string
  sensitive   = true
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.m5.large"
}

variable "allocated_storage" {
  description = "Allocated storage in GiB"
  type        = number
  default     = 100
}

variable "engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "15.4"
}

variable "backup_retention_period" {
  description = "Backup retention in days"
  type        = number
  default     = 7
}
