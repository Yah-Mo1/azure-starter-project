output "backend_address_pool_id" {
  description = "The ID of the backend address pool of the Application Gateway"
  value       = one(azurerm_application_gateway.app-gateway.backend_address_pool).id
}
