output "storage_account_name" { value = azurerm_storage_account.this.name }
output "container_names" { value = keys(azurerm_storage_container.this) }
output "primary_blob_endpoint" { value = azurerm_storage_account.this.primary_blob_endpoint }
