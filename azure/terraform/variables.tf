variable "tags" {
  description = "A map of tags to apply to all provisioned resources."
  type        = map(string)
  default = {
    "Project"     = "Jira on Azure"
    "ManagedBy"   = "Terraform"
    "Environment" = "Production"
  }
}