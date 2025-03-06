resource "azurerm_resource_group" "coderco" {
  name     = var.resource_group_name
  location = var.location
}

locals {
  backend_address_pool_name      = "${var.app_gateway_name}-beap"
  frontend_port_name             = "${var.app_gateway_name}-feport"
  frontend_ip_configuration_name = "${var.app_gateway_name}-feip"
  http_setting_name              = "${var.app_gateway_name}-be-htst"
  listener_name                  = "${var.app_gateway_name}-httplstn"
  request_routing_rule_name      = "${var.app_gateway_name}-rqrt"
  redirect_configuration_name    = "${var.app_gateway_name}-rdrcfg"
}

resource "azurerm_application_gateway" "app-gateway" {
  name                = var.app_gateway_name
  location            = azurerm_resource_group.coderco.location
  resource_group_name = azurerm_resource_group.coderco.name

  sku {
    name     = var.app_gateway_sku
    tier     = var.app_gateway_tier
    capacity = var.app_gateway_capacity
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = var.subnet_id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = var.public_ip_id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    priority                   = 9
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}
