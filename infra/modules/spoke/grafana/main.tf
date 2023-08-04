
variable "prefix" {
  type        = string
}

variable "location" {
  type        = string
}

variable "resource_group_name" {
  type        = string
}

variable "prometheus_id" {
  type        = string
}

variable "grafana_admin_email" {
  type        = string
}


resource "azurerm_user_assigned_identity" "grafana_identity" {
  resource_group_name = var.resource_group_name
  location            = var.location

  name = "${var.prefix}-grafana-msi"
}

resource "azurerm_role_assignment" "grafana_identity_assignment" {
  scope                = "subscriptions/14506188-80f8-4dc6-9b28-250051fc4ee4/resourceGroups/${var.resource_group_name}"
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.grafana_identity.principal_id
}

resource "azurerm_dashboard_grafana" "graphana" {
  name                              = "${var.prefix}-graf"
  resource_group_name               = var.resource_group_name
  location                          = var.location
  api_key_enabled                   = true
  deterministic_outbound_ip_enabled = true
  public_network_access_enabled     = true

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.grafana_identity.id]
  }

  azure_monitor_workspace_integrations {
    resource_id = var.prometheus_id
  }
  
  tags = {
    key = "prefix"
    value = var.prefix
  }
}

resource "azurerm_role_assignment" "grafana_admin_email" {
  scope                = azurerm_dashboard_grafana.graphana.id
  role_definition_name = "Grafana Admin"
  principal_id         = var.grafana_admin_email
}
