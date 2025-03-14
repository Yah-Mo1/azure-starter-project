resource "azurerm_resource_group" "coderco" {
  name     = var.resource_group_name
  location = var.resource_group_location
}


resource "azurerm_linux_virtual_machine_scale_set" "coderco_vmss" {
  name                = var.vmss_name
  location            = azurerm_resource_group.coderco.location
  resource_group_name = azurerm_resource_group.coderco.name

  sku       = var.vmss_sku
  instances = var.vmss_instances
  zones     = var.vmss_zones

  admin_username = var.admin_username

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  network_interface {
    name    = "${var.vmss_name}-nic"
    primary = true

    ip_configuration {
      name                                         = "${var.vmss_name}-ipconfig"
      subnet_id                                    = var.subnet_id
      application_gateway_backend_address_pool_ids = var.app_gateway_backend_address_pool_ids
      primary                                      = true
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

resource "azurerm_monitor_autoscale_setting" "coderco_vmss_autoscale" {
  name                = "${var.vmss_name}-autoScaling"
  location            = azurerm_resource_group.coderco.location
  resource_group_name = azurerm_resource_group.coderco.name
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.coderco_vmss.id

  profile {
    name = "coderCo-profile"

    capacity {
      default = var.vmss_instances
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


resource "azurerm_monitor_diagnostic_setting" "vmss_logs" {
  name                       = "vmss-diagnostics"
  target_resource_id         = azurerm_linux_virtual_machine_scale_set.coderco_vmss.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  storage_account_id = var.storage_account_id

  #  enabled_log {
  #   category = "Administrative"
  # }
 
  # enabled_log {
  #   category = "ServiceHealth"
  # }

  


  # enabled_log {
  #   category = "ResourceHealth"
  # }

  # enabled_log {
  #   category = "AuditEvent"
  # }
  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
