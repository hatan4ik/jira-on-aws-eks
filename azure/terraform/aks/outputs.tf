output "name" {
  value       = azurerm_kubernetes_cluster.this.name
  description = "AKS cluster name."
}

output "kube_config_raw" {
  value       = azurerm_kubernetes_cluster.this.kube_config_raw
  description = "Raw kubeconfig for AKS."
  sensitive   = true
}

output "oidc_issuer_url" {
  value       = azurerm_kubernetes_cluster.this.oidc_issuer_url
  description = "OIDC issuer URL for AKS."
}
