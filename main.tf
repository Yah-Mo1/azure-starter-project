
resource "azurerm_resource_group" "coderco" {
  name     = "coderco-tech-test"
  location = "UK South"

}

resource "azurerm_virtual_network" "coderco_vnet" {
  name                = "coderco-vnet"
  location            = azurerm_resource_group.coderco.location
  resource_group_name = azurerm_resource_group.coderco.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "coderco_appgw_subnet" {
  name                 = "coderco-appgw-subnet"
  resource_group_name  = azurerm_resource_group.coderco.name
  virtual_network_name = azurerm_virtual_network.coderco_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "coderco_vmss_subnet" {
  name                 = "coderco-vmss-subnet"
  resource_group_name  = azurerm_resource_group.coderco.name
  virtual_network_name = azurerm_virtual_network.coderco_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}
resource "azurerm_public_ip" "coderco_ip" {
  name                = "coderco-public-ip"
  location            = azurerm_resource_group.coderco.location
  resource_group_name = azurerm_resource_group.coderco.name
  allocation_method   = "Static"
}


locals {
  backend_address_pool_name      = "${azurerm_virtual_network.coderco_vnet.name}-beap"
  frontend_port_name             = "${azurerm_virtual_network.coderco_vnet.name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.coderco_vnet.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.coderco_vnet.name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.coderco_vnet.name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.coderco_vnet.name}-rqrt"
  redirect_configuration_name    = "${azurerm_virtual_network.coderco_vnet.name}-rdrcfg"
}
resource "azurerm_application_gateway" "app-gateway" {
  name                = "coderco-appgateway"
  location            = azurerm_resource_group.coderco.location
  resource_group_name = azurerm_resource_group.coderco.name

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.coderco_appgw_subnet.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.coderco_ip.id
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


resource "azurerm_network_security_group" "coderco_nsg" {
  name                = "coderco-nsg"
  location            = azurerm_resource_group.coderco.location
  resource_group_name = azurerm_resource_group.coderco.name
}

locals {
  inbound_ports_map = {
    "100" : "80", # If the key starts with a number, you must use the colon syntax ":" instead of "="
    "110" : "443",
    "130" : "65200-65535"
  }
}

## NSG Inbound Rule for Azure Application Gateway Subnets
resource "azurerm_network_security_rule" "nsg_rule_inbound" {
  for_each                    = local.inbound_ports_map
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
    depends_on = [azurerm_network_security_group.coderco_nsg]  # Ensure NSG is created first

}

resource "azurerm_subnet_network_security_group_association" "coderco_nsg_assoc" {
  subnet_id                 = azurerm_subnet.coderco_vmss_subnet.id
  network_security_group_id = azurerm_network_security_group.coderco_nsg.id

}


//TODO: Register your current subscription to have microsoft.compute service provider
resource "azurerm_linux_virtual_machine_scale_set" "coderco_vmss" {
  name                = "coderco-vmss"
  resource_group_name = azurerm_resource_group.coderco.name
  location            = azurerm_resource_group.coderco.location


  sku = "Standard_D2s_v3"
  #Update the Virtual Machine Scale Set (VMSS) to run 3 instances.
  # instances      = 2
  instances = 3
  #    # Distribute instances across multiple Availability Zones
  zones = ["1", "2", "3"]

  admin_username = "codercoadmin"


  admin_ssh_key {
    username   = "codercoadmin"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  network_interface {
    name    = "coderco-nic"
    primary = true

    ip_configuration {
      name                                         = "coderco-ipconfig"
      subnet_id                                    = azurerm_subnet.coderco_vmss_subnet.id
      application_gateway_backend_address_pool_ids = [for pool in azurerm_application_gateway.app-gateway.backend_address_pool : pool.id]

      primary = true
    }
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  custom_data = base64encode(<<EOF
#!/bin/bash

sudo apt update
sudo apt install -y apache2
sudo systemctl enable apache2
sudo systemctl start apache2
sudo ufw allow 80/tcp
echo "Hello! Your CoderCo Tech Test VM is working!" | sudo tee /var/www/html/index.html
sudo systemctl restart apache2



EOF
  )

  tags = {
    environment = "test"
  }
}


resource "azurerm_monitor_autoscale_setting" "example" {
  name                = "coderco-vmss-autoScaling"
  resource_group_name = azurerm_resource_group.coderco.name
  location            = azurerm_resource_group.coderco.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.coderco_vmss.id

  profile {
    name = "coderCo-profile"

    capacity {
      default = 3
      minimum = 3
      maximum = 6
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.coderco_vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 75
        metric_namespace   = "microsoft.compute/virtualmachinescalesets"
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.coderco_vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 25
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }

  predictive {
    scale_mode      = "Enabled"
    look_ahead_time = "PT5M"
  }
}
