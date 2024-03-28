data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  name                        = var.key_vault_name
  location                    = var.region
  resource_group_name         = var.resource_group
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"

  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  access_policy {
        tenant_id = data.azurerm_client_config.current.tenant_id
        object_id = var.service_principal_id
        key_permissions = ["Create", "Get", "List", "Update", "Backup", "Restore", "Purge", "Recover", "Delete", "GetRotationPolicy", "SetRotationPolicy"]
    }
  access_policy {
        tenant_id = data.azurerm_client_config.current.tenant_id
        object_id = data.azurerm_client_config.current.object_id
        key_permissions = ["Create", "Get", "List", "Update", "Backup", "Restore", "Purge", "Recover", "Delete", "GetRotationPolicy", "SetRotationPolicy"]
    }
}


resource "azurerm_key_vault_key" "sops-key" {
  name = "sops-key"
  key_vault_id = azurerm_key_vault.kv.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
  ]
  
}