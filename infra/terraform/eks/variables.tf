variable "project_name" {
  description = "Project name prefix"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs where EKS components run"
  type        = list(string)
}

variable "cluster_version" {
  description = "EKS control plane version"
  type        = string
  default     = "1.30"
}

variable "node_instance_type" {
  description = "Instance type for managed node group"
  type        = string
  default     = "m5.xlarge"
}

variable "node_desired_size" {
  description = "Desired node count for Jira workloads"
  type        = number
  default     = 3
}

variable "node_min_size" {
  description = "Minimum node count"
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum node count"
  type        = number
  default     = 6
}

variable "node_ami_type" {
  description = "AMI type for managed nodes"
  type        = string
  default     = "AL2_x86_64"
}

variable "node_disk_size" {
  description = "Node disk size in GiB"
  type        = number
  default     = 50
}

variable "node_capacity_type" {
  description = "Capacity type for the node group (ON_DEMAND or SPOT)"
  type        = string
  default     = "ON_DEMAND"
}
