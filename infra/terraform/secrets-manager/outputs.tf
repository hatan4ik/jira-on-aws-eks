output "jira_db_password_secret_arn" {
  value = aws_secretsmanager_secret.jira_db_password.arn
}

output "jira_license_secret_arn" {
  value = aws_secretsmanager_secret.jira_license.arn
}