output "public_ip" {
  description = "The Public IP"
  value       = azurerm_public_ip.coderco_ip

}

output "appgw_subnet_id" {
  description = "ID of the Application Gateway subnet"
  value       = values(azurerm_subnet.coderco_subnets)[0].id
}
output "vmss_subnet_id" {
  description = "ID of the Application Gateway subnet"
  value       = values(azurerm_subnet.coderco_subnets)[1].id
}
