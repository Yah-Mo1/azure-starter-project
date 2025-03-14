module "vnet" {
  source                      = "./modules/vnet"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  vnet_name                   = var.vnet_name
  vnet_address_space          = var.vnet_address_space
  subnets                     = var.subnets
  network_security_group_name = var.network_security_group_name
  public_ip_name              = var.public_ip_name
  public_ip_allocation        = var.public_ip_allocation
  inbound_ports_map           = var.inbound_ports_map
}

module "alb" {
  source               = "./modules/alb"
  app_gateway_capacity = var.app_gateway_capacity
  app_gateway_name     = var.app_gateway_name
  app_gateway_sku      = var.app_gateway_sku
  app_gateway_tier     = var.app_gateway_tier
  subnet_id            = module.vnet.appgw_subnet_id
  public_ip_id         = module.vnet.public_ip.id
}

module "montior" {
  source                     = "./modules/monitoring"
  resource_group_name        = var.resource_group_name
  storage_account_name       = var.storage_account_name
  vmss_id                    = module.vmss.vmss_id
  action_group_name          = var.action_group_name
  action-group-email-name    = var.action_group_email_name
  action-group-email_address = var.email_address
  la_workspace_name          = var.log_analytics_workspace_name
}

module "vmss" {
  source                               = "./modules/vmss"
  admin_username                       = var.admin_username
  resource_group_location              = var.location
  resource_group_name                  = var.resource_group_name
  subnet_id                            = module.vnet.vmss_subnet_id
  ssh_public_key_path                  = var.ssh_public_key_path
  app_gateway_backend_address_pool_ids = [module.alb.backend_address_pool_id]
  vmss_sku                             = var.vmss_sku
  vmss_name                            = var.vmss_name
  vmss_zones                           = var.vmss_zones
  log_analytics_workspace_id           = module.montior.log_analytics_workspace_id
  storage_account_id                   = module.montior.storage_account_id
}