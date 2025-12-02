output "resource_group_name" {
  value       = azurerm_resource_group.this.name
  description = "Resource group hosting all Azure resources."
}

output "aks_cluster_name" {
  value       = module.aks.name
  description = "AKS cluster name."
}

output "aks_kubeconfig" {
  value       = module.aks.kube_config_raw
  description = "Raw kubeconfig for the AKS cluster."
  sensitive   = true
}

output "postgres_fqdn" {
  value       = module.postgres.fqdn
  description = "PostgreSQL Flexible Server FQDN."
}

output "storage_account" {
  value       = module.storage.account_name
  description = "Storage account hosting the Jira shared home."
}

output "storage_share_name" {
  value       = module.storage.share_name
  description = "Azure Files share name for Jira shared home."
}
