resource "azurerm_resource_group" "coderco" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "storage_account_monitoring_logs" {
  name                     = var.storage_account_name
  location                 = azurerm_resource_group.coderco.location
  resource_group_name      = azurerm_resource_group.coderco.name
  account_tier             = "Standard"
  account_replication_type = "LRS"

}
resource "azurerm_log_analytics_workspace" "la-workspace" {
  name                = var.la_workspace_name
  location            = azurerm_resource_group.coderco.location
  resource_group_name = azurerm_resource_group.coderco.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}





// Azure Monitor alerts
resource "azurerm_monitor_action_group" "azure_monitor_ag" {
  name                = var.action_group_name
  resource_group_name = azurerm_resource_group.coderco.name
  short_name          = "montior-ag"


  email_receiver {
    name                    = var.action-group-email-name
    email_address           = var.action-group-email_address
    use_common_alert_schema = true
  }

}

resource "azurerm_monitor_metric_alert" "cpu_alert" {
  name                = var.cpu_alert
  resource_group_name = azurerm_resource_group.coderco.name
  scopes              = [var.vmss_id]
  description         = "Alert when CPU usage is high"
  severity            = 3
  frequency           = "PT1M"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachineScaleSets"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 60
  }

  action {
    action_group_id = azurerm_monitor_action_group.azure_monitor_ag.id
  }

  depends_on = [azurerm_monitor_action_group.azure_monitor_ag]
}
