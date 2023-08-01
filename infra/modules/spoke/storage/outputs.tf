output "storage_name" {
  value = azurerm_storage_account.storage.name
}

output "storage_key" {
  value = azurerm_storage_account.storage.primary_access_key
}