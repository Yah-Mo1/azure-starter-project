output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.la-workspace.id

}

output "storage_account_id" {
  value = azurerm_storage_account.storage_account_monitoring_logs.id

}