# Mostly taken from here: https://techcommunity.microsoft.com/t5/fasttrack-for-azure/can-i-create-an-azure-container-apps-in-terraform-yes-you-can/ba-p/3570694

locals {
  revision_name = "v15"
}
resource "azurerm_user_assigned_identity" "aca_identity" {
  resource_group_name = var.resource_group_name
  location            = var.location

  name = "${var.prefix}-func-msi"
}

resource "azurerm_role_assignment" "aca_identity_assignment" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.aca_identity.principal_id
}

resource "azurerm_role_assignment" "aca_identity_storage_assignment" {
  scope                = var.storage_id
  role_definition_name = "Storage Queue Data Contributor"
  principal_id         = azurerm_user_assigned_identity.aca_identity.principal_id
}

resource "azurerm_container_app_environment" "managed_environment" {
  name                           = "${var.prefix}-aca-env"
  location                       = var.location
  resource_group_name            = var.resource_group_name
  log_analytics_workspace_id     = var.loganalytics_id
  infrastructure_subnet_id       = var.subnet_id
  internal_load_balancer_enabled = false
  tags                           = var.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_container_app" "client_app" {
  name                         = "clientapp"
  resource_group_name          = var.resource_group_name
  container_app_environment_id = azurerm_container_app_environment.managed_environment.id
  tags                         = var.tags
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aca_identity.id]
  }

  ingress {
    external_enabled = true
    target_port      = 3000
    transport        = "http"
    traffic_weight {
      label           = local.revision_name
      latest_revision = true
      revision_suffix = local.revision_name
      percentage      = 100
    }
  }

  registry {
    server   = var.acr_url
    identity = azurerm_user_assigned_identity.aca_identity.id
  }

  template {
    container {
      name   = "client"
      image  = "crgaracaeuss1acr.azurecr.io/client:latest"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "APP_PORT"
        value = 3000
      }
      env {
        name  = "QUEUE_STORAGE_ACCOUNT_URL"
        value = var.storage_queue_url
      }
      env {
        name = "AZURE_CLIENT_ID"
        value = azurerm_user_assigned_identity.aca_identity.client_id
      }
    }
    min_replicas    = 1
    max_replicas    = 1
    revision_suffix = local.revision_name
  }
}


resource "azurerm_container_app" "chunker_app" {
  name                         = "chunkerapp"
  resource_group_name          = var.resource_group_name
  container_app_environment_id = azurerm_container_app_environment.managed_environment.id
  tags                         = var.tags
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aca_identity.id]
  }

  ingress {
    external_enabled = true
    target_port      = 3000
    transport        = "http"
    traffic_weight {
      label           = local.revision_name
      latest_revision = true
      revision_suffix = local.revision_name
      percentage      = 100
    }
  }

  registry {
    server   = var.acr_url
    identity = azurerm_user_assigned_identity.aca_identity.id
  }

  template {
    container {
      name   = "chunker"
      image  = "crgaracaeuss1acr.azurecr.io/chunker:latest"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "APP_PORT"
        value = 3000
      }
      env {
        name  = "QUEUE_STORAGE_ACCOUNT_URL"
        value = var.storage_queue_url
      }
      env {
        name = "AZURE_CLIENT_ID"
        value = azurerm_user_assigned_identity.aca_identity.client_id
      }
    }
    min_replicas    = 1
    max_replicas    = 1
    revision_suffix = local.revision_name
  }
}