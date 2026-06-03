resource "azurerm_storage_account" "this" {
  name                            = var.name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false

  network_rules {
    default_action             = "Deny"
    bypass                     = ["AzureServices"]
    ip_rules                   = var.allowed_ip_ranges
    virtual_network_subnet_ids = var.vnet_subnet_ids
  }
}

resource "azurerm_storage_share" "qdrant" {
  name                 = "qdrantshare"
  storage_account_id = azurerm_storage_account.this.id
  quota                = 102400
}
