output "dashboard_url" {
  description = "CloudWatch dashboard URL"
  value       = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.jira.dashboard_name}"
}

output "sns_topic_arn" {
  description = "SNS topic ARN for alerts"
  value       = aws_sns_topic.alerts.arn
}

output "log_group_names" {
  description = "CloudWatch log group names"
  value = {
    jira_application = aws_cloudwatch_log_group.jira_application.name
    eks_cluster      = aws_cloudwatch_log_group.eks_cluster.name
  }
}