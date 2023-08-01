

variable "prefix" {
  description = "prefix"
  type        = string
}

variable "location" {
  description = "Location"
  type        = string
}

variable "resource_group_name" {
  description = "RG Name"
  type        = string
}

resource "azurerm_container_registry" "acr" {
  name                = replace("${var.prefix}-acr", "-", "")
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  admin_enabled       = true
}

output "acr_id" {
  value = azurerm_container_registry.acr.id
}
output "acr_username" {
  value = azurerm_container_registry.acr.admin_username
}
output "acr_password" {
  value = azurerm_container_registry.acr.admin_password
}
output "acr_url" {
  value = azurerm_container_registry.acr.login_server
}