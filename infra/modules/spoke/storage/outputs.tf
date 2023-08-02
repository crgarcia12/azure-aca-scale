output "storage_name" {
  value = azurerm_storage_account.storage.name
}

output "storage_key" {
  value = azurerm_storage_account.storage.primary_access_key
}

output "storage_queue_url" {
  value = "https://${azurerm_storage_account.storage.name}.queue.core.windows.net"
}

output "storage_id" {
  value = azurerm_storage_account.storage.id
}