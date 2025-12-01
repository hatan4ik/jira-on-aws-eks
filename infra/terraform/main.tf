terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Core networking (VPC, subnets, routing)
module "network" {
  source = "./network"
}

# EKS cluster and node groups
module "eks" {
  source = "./eks"

  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids
}

# RDS (PostgreSQL / Aurora) for Jira
module "rds" {
  source = "./rds"

  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids
  db_name            = var.jira_db_name
  username           = var.jira_db_username
  password           = var.jira_db_password
}

# EFS for shared Jira home
module "efs" {
  source = "./efs"

  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids
}

# ALB Ingress Controller (AWS Load Balancer Controller)
module "alb_ingress_controller" {
  source = "./alb-ingress-controller"

  cluster_name = module.eks.cluster_name
  vpc_id       = module.network.vpc_id
}
