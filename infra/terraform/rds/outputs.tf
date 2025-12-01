output "db_endpoint" {
  value = aws_db_instance.jira.address
}

output "security_group_id" {
  value = aws_security_group.jira_db.id
}
