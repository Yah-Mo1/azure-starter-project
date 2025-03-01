
resource "azurerm_resource_group" "coderco" {
  name     = "coderco-tech-test"
  location = "West Europe"
}

resource "azurerm_virtual_network" "coderco_vnet" {
  name                = "coderco-vnet"
  location            = azurerm_resource_group.coderco.location
  resource_group_name = azurerm_resource_group.coderco.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "coderco_subnet" {
  name                 = "coderco-subnet"
  resource_group_name  = azurerm_resource_group.coderco.name
  virtual_network_name = azurerm_virtual_network.coderco_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "coderco_ip" {
  name                = "coderco-public-ip"
  location            = azurerm_resource_group.coderco.location
  resource_group_name = azurerm_resource_group.coderco.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "coderco_lb" {
  name                = "coderco-lb"
  location            = azurerm_resource_group.coderco.location
  resource_group_name = azurerm_resource_group.coderco.name

  frontend_ip_configuration {
    name                 = "coderco-lb-fe"
    public_ip_address_id = azurerm_public_ip.coderco_ip.id
  }
}

resource "azurerm_lb_backend_address_pool" "coderco_backend_pool" {
  name            = "coderco-backend-pool"
  loadbalancer_id = azurerm_lb.coderco_lb.id
}


resource "azurerm_network_security_group" "coderco_nsg" {
  name                = "coderco-nsg"
  location            = azurerm_resource_group.coderco.location
  resource_group_name = azurerm_resource_group.coderco.name
}

resource "azurerm_network_security_rule" "coderco_http" {
  resource_group_name         = azurerm_resource_group.coderco.name
  name                        = "Allow-HTTP"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.coderco_nsg.name
}

resource "azurerm_subnet_network_security_group_association" "coderco_nsg_assoc" {
  subnet_id                 = azurerm_subnet.coderco_subnet.id
  network_security_group_id = azurerm_network_security_group.coderco_nsg.id
}

//TODO: Register your current subscription to have microsoft.compute service provider
resource "azurerm_linux_virtual_machine_scale_set" "coderco_vmss" {
  name                = "coderco-vmss"
  resource_group_name = azurerm_resource_group.coderco.name
  location            = azurerm_resource_group.coderco.location


  sku            = "Standard_DS1_v2"
  instances      = 2
  admin_username = "codercoadmin"

  admin_ssh_key {
    username   = "codercoadmin"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  network_interface {
    name    = "coderco-nic"
    primary = true

    ip_configuration {
      name                                   = "coderco-ipconfig"
      subnet_id                              = azurerm_subnet.coderco_subnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.coderco_backend_pool.id]

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
echo "Hello! Your CoderCo Tech Test VM is working!" > /var/www/html/index.html
nohup busybox httpd -f -p 80 &
EOF
  )

  tags = {
    environment = "test"
  }
}
