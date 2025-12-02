variable "project_name" {
  description = "Project name prefix"
  type        = string
  default     = "jira-eks"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

variable "availability_zones" {
  description = "Availability zones to use"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "eks_cluster_version" {
  description = "EKS control plane version"
  type        = string
  default     = "1.30"
}

variable "eks_node_instance_type" {
  description = "Instance type for the Jira node group"
  type        = string
  default     = "m5.xlarge"
}

variable "eks_node_desired_size" {
  description = "Desired nodes for the Jira node group"
  type        = number
  default     = 3
}

variable "eks_node_min_size" {
  description = "Minimum nodes for the Jira node group"
  type        = number
  default     = 2
}

variable "eks_node_max_size" {
  description = "Maximum nodes for the Jira node group"
  type        = number
  default     = 6
}

variable "jira_db_name" {
  type        = string
  description = "Jira database name"
  default     = "jira"
}

variable "jira_db_username" {
  type        = string
  description = "Jira database username"
  default     = "jira_user"
}

variable "jira_db_password" {
  type        = string
  description = "Jira database password"
  sensitive   = true
}

variable "rds_instance_class" {
  description = "Instance class for Jira RDS"
  type        = string
  default     = "db.m5.large"
}

variable "rds_allocated_storage" {
  description = "Allocated storage for Jira RDS (GiB)"
  type        = number
  default     = 100
}

variable "rds_backup_retention_period" {
  description = "Backup retention period for Jira RDS (days)"
  type        = number
  default     = 7
}

variable "jira_license_key" {
  description = "Jira Data Center license key"
  type        = string
  sensitive   = true
  default     = ""
}
