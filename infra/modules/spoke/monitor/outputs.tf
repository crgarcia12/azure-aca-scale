
output "instrumentation_key" {
  value = azurerm_application_insights.appinsights.instrumentation_key
}

output "connection_string" {
  value = azurerm_application_insights.appinsights.connection_string
}

output "loganalytics_id" {
  value = azurerm_log_analytics_workspace.la.id
}

output "prometheus_id" {
  value = azurerm_monitor_workspace.prometheus.id
}