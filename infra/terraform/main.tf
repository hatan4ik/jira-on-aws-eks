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

  project_name         = var.project_name
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

# EKS cluster and node groups
module "eks" {
  source = "./eks"

  project_name       = var.project_name
  private_subnet_ids = module.network.private_subnet_ids
  cluster_version    = var.eks_cluster_version
  node_instance_type = var.eks_node_instance_type
  node_desired_size  = var.eks_node_desired_size
  node_min_size      = var.eks_node_min_size
  node_max_size      = var.eks_node_max_size
}

# RDS (PostgreSQL / Aurora) for Jira
module "rds" {
  source = "./rds"

  project_name            = var.project_name
  vpc_id                  = module.network.vpc_id
  private_subnet_ids      = module.network.private_subnet_ids
  vpc_cidr                = var.vpc_cidr
  db_name                 = var.jira_db_name
  username                = var.jira_db_username
  password                = var.jira_db_password
  instance_class          = var.rds_instance_class
  allocated_storage       = var.rds_allocated_storage
  backup_retention_period = var.rds_backup_retention_period
}

# EFS for shared Jira home
module "efs" {
  source = "./efs"

  project_name       = var.project_name
  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids
  vpc_cidr           = var.vpc_cidr
}

# ALB Ingress Controller (AWS Load Balancer Controller)
module "alb_ingress_controller" {
  source = "./alb-ingress-controller"

  project_name = var.project_name
}
