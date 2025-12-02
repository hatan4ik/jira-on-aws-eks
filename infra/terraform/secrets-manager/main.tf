resource "aws_secretsmanager_secret" "jira_db_password" {
  name        = "${var.project_name}-jira-db-password"
  description = "Jira database password"
}

resource "aws_secretsmanager_secret_version" "jira_db_password" {
  secret_id     = aws_secretsmanager_secret.jira_db_password.id
  secret_string = var.jira_db_password
}

resource "aws_secretsmanager_secret" "jira_license" {
  name        = "${var.project_name}-jira-license"
  description = "Jira Data Center license key"
}

resource "aws_secretsmanager_secret_version" "jira_license" {
  secret_id     = aws_secretsmanager_secret.jira_license.id
  secret_string = var.jira_license_key
}