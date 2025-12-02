resource "azurerm_public_ip" "this" {
  name                = "${var.prefix}-appgw-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_user_assigned_identity" "agic" {
  name                = "${var.prefix}-agic-identity"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_application_gateway" "this" {
  name                = "${var.prefix}-appgw"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  waf_configuration {
    enabled                  = true
    firewall_mode            = "Prevention"
    rule_set_version         = "3.2"
    file_upload_limit_mb     = 100
    max_request_body_size_kb = 128
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.agic.id]
  }

  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = var.subnet_id
  }

  frontend_port {
    name = "httpPort"
    port = 80
  }

  frontend_port {
    name = "httpsPort"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "appGatewayFrontendIp"
    public_ip_address_id = azurerm_public_ip.this.id
  }

  backend_address_pool {
    name = "defaultBackendAddressPool" # AGIC will manage this
  }

  backend_http_settings {
    name                  = "defaultHttpSettings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30
  }

  http_listener {
    name                           = "defaultListener"
    frontend_ip_configuration_name = "appGatewayFrontendIp"
    frontend_port_name             = "httpPort"
    protocol                       = "Http"
  }

  request_routing_rule {
    name               = "defaultRoutingRule"
    rule_type          = "Basic"
    http_listener_name = "defaultListener"
    backend_address_pool_name  = "defaultBackendAddressPool"
    backend_http_settings_name = "defaultHttpSettings"
  }

  autoscale_configuration {
    min_capacity = 0
    max_capacity = 10
  }
}
