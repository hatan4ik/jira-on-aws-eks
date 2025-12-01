output "vpc_id" {
  value = module.network.vpc_id
}

output "private_subnet_ids" {
  value = module.network.private_subnet_ids
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "jira_db_endpoint" {
  value = module.rds.db_endpoint
}

output "jira_efs_id" {
  value = module.efs.efs_id
}
