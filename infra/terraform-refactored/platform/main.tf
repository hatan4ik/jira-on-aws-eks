# REFACTORED: Platform layer - O(1) complexity, DIP compliant
terraform {
  required_version = ">= 1.6.0"
  
  backend "s3" {
    key = "platform/terraform.tfstate"
  }
}

# DIP: Depend on abstractions, not concretions
data "terraform_remote_state" "foundation" {
  backend = "s3"
  config = {
    bucket = var.state_bucket
    key    = "foundation/terraform.tfstate"
    region = var.region
  }
}

# SRP: Single responsibility - platform services only
module "eks_platform" {
  source = "../modules/eks-platform"
  
  foundation_contract = data.terraform_remote_state.foundation.outputs.foundation_contract
  platform_config = var.platform_config
}

module "data_platform" {
  source = "../modules/data-platform"
  
  foundation_contract = data.terraform_remote_state.foundation.outputs.foundation_contract
  data_config = var.data_config
}

# OCP: Open for extension via contract interface
output "platform_contract" {
  value = {
    eks_cluster_name = module.eks_platform.cluster_name
    eks_endpoint = module.eks_platform.cluster_endpoint
    database_endpoint = module.data_platform.database_endpoint
    storage_config = module.data_platform.storage_config
  }
}