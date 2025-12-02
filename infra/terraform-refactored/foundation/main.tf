# REFACTORED: Foundation layer - O(1) complexity per layer
terraform {
  required_version = ">= 1.6.0"
  
  backend "s3" {
    key = "foundation/terraform.tfstate"
  }
}

# SRP: Single responsibility - network foundation only
module "network_foundation" {
  source = "../modules/network-foundation"
  
  environment = var.environment
  region      = var.region
  cidr_config = var.cidr_config
}

# DIP: Abstract interface for dependent layers
output "foundation_contract" {
  value = {
    vpc_id = module.network_foundation.vpc_id
    subnet_ids = module.network_foundation.subnet_ids
    security_group_ids = module.network_foundation.security_group_ids
  }
}