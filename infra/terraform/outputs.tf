output "eks_cluster_name" {
  value = aws_eks_cluster.this.name
}

output "jira_db_endpoint" {
  value = aws_db_instance.jira.address
}

output "jira_efs_id" {
  value = aws_efs_file_system.jira.id
}
