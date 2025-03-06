resource "azurerm_resource_group" "coderco" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "coderco_vnet" {
  name                = var.vnet_name
  location            = azurerm_resource_group.coderco.location
  resource_group_name = azurerm_resource_group.coderco.name
  address_space       = var.vnet_address_space
}

resource "azurerm_subnet" "coderco_subnets" {
  for_each = var.subnets

  name                 = each.value.name
  resource_group_name  = azurerm_resource_group.coderco.name
  virtual_network_name = azurerm_virtual_network.coderco_vnet.name
  address_prefixes     = each.value.address_prefixes
}

resource "azurerm_public_ip" "coderco_ip" {
  name                = var.public_ip_name
  location            = azurerm_resource_group.coderco.location
  resource_group_name = azurerm_resource_group.coderco.name
  allocation_method   = var.public_ip_allocation
}

resource "azurerm_network_security_group" "coderco_nsg" {
  name                = var.network_security_group_name
  location            = azurerm_resource_group.coderco.location
  resource_group_name = azurerm_resource_group.coderco.name
}

resource "azurerm_network_security_rule" "nsg_rule_inbound" {
  for_each                    = var.inbound_ports_map
  name                        = "Rule-Port-${each.value}"
  priority                    = each.key
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = each.value
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.coderco.name
  network_security_group_name = azurerm_network_security_group.coderco_nsg.name
  depends_on                  = [azurerm_network_security_group.coderco_nsg]
}

resource "azurerm_subnet_network_security_group_association" "coderco_nsg_assoc" {
  subnet_id                 = values(azurerm_subnet.coderco_subnets)[0].id
  network_security_group_id = azurerm_network_security_group.coderco_nsg.id
}
