# REFACTORED: Application layer - ISP compliant, minimal interfaces
terraform {
  required_version = ">= 1.6.0"
  
  backend "s3" {
    key = "application/terraform.tfstate"
  }
}

# DIP: Abstract dependencies via remote state
data "terraform_remote_state" "platform" {
  backend = "s3"
  config = {
    bucket = var.state_bucket
    key    = "platform/terraform.tfstate"
    region = var.region
  }
}

# SRP: Application-specific resources only
module "jira_application" {
  source = "../modules/jira-application"
  
  platform_contract = data.terraform_remote_state.platform.outputs.platform_contract
  application_config = var.application_config
}

# Circuit breaker implementation
module "resilience_patterns" {
  source = "../modules/resilience"
  
  application_name = "jira"
  circuit_breaker_config = var.circuit_breaker_config
}