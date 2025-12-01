output "efs_id" {
  value = aws_efs_file_system.jira.id
}

output "security_group_id" {
  value = aws_security_group.jira_efs.id
}
