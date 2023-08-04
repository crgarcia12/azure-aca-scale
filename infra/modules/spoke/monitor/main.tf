resource "azurerm_log_analytics_workspace" "la" {
  name                = "${var.prefix}-la"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 60
  tags = {
    prefix = var.prefix
  }
}

resource "azurerm_application_insights" "appinsights" {
  name                = "${var.prefix}-appinsights"
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.la.id
  application_type    = "web"
  tags = {
    prefix = var.prefix
  }
}

resource "azurerm_monitor_workspace" "prometheus" {
  name                = "${var.prefix}-prometheus"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags = {
    prefix = var.prefix
  }
}