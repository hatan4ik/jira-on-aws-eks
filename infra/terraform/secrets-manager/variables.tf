variable "project_name" {
  description = "Project name prefix"
  type        = string
}

variable "jira_db_password" {
  description = "Jira database password"
  type        = string
  sensitive   = true
}

variable "jira_license_key" {
  description = "Jira Data Center license key"
  type        = string
  sensitive   = true
  default     = ""
}