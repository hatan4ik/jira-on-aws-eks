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
