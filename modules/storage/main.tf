resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

resource "azurerm_storage_account" "this" {
  name                            = lower(replace("${var.name_prefix}${random_string.suffix.result}", "-", ""))
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  enable_https_traffic_only       = true
  public_network_access_enabled   = false
  allow_nested_items_to_be_public = false
  tags                            = var.tags

  lifecycle { prevent_destroy = true }
}

resource "azurerm_storage_container" "this" {
  for_each              = var.containers
  name                  = each.value
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}
