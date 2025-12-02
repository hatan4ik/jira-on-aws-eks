resource "azurerm_kubernetes_cluster" "this" {
  name                = "${var.prefix}-aks"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version
  tags                = var.tags

  default_node_pool {
    name                = "system"
    vm_size             = var.node_vm_size
    vnet_subnet_id      = var.vnet_subnet_id
    type                = "VirtualMachineScaleSets"
    enable_auto_scaling = true
    min_count           = var.system_node_pool_min_count
    max_count           = var.system_node_pool_max_count
    mode                = "System"
  }

  identity {
    type = "SystemAssigned"
  }

  oidc_issuer_enabled       = var.enable_oidc_issuer
  workload_identity_enabled = var.enable_workload_identity

  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
    load_balancer_sku = "standard"
  }

  role_based_access_control_enabled = true

  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name                  = "user"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = var.user_node_pool_vm_size
  vnet_subnet_id        = var.vnet_subnet_id
  enable_auto_scaling   = true
  min_count             = var.user_node_pool_min_count
  max_count             = var.user_node_pool_max_count
  mode                  = "User"
  tags                  = var.tags
}
