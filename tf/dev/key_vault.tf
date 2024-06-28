resource "azurerm_key_vault" "kv" {
  name                        = "${local.resource_prefix}-keyvault-${local.environment}"
  location                    = local.region
  resource_group_name         = local.resource_group
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"

  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

}

resource "azurerm_key_vault_access_policy" "admin_group_access_policy" {
        key_vault_id = azurerm_key_vault.kv.id
        tenant_id = data.azurerm_client_config.current.tenant_id
        object_id = local.admin_group_id
          key_permissions = [
          "Get",
          "List",
          "Update",
          "Create",
          "Import",
          "Delete",
          "Recover",
          "Backup",
          "Restore",
          "GetRotationPolicy",
          "SetRotationPolicy",
          "Rotate",
          "Purge",
          "Encrypt",
          "Decrypt"
        ]

        secret_permissions = [
          "Get",
          "List",
          "Set",
          "Delete",
          "Recover",
          "Backup",
          "Restore",
          "Purge",
        ]

  }

resource "azurerm_key_vault_access_policy" "uai_access_policy" {
        key_vault_id = azurerm_key_vault.kv.id
        tenant_id = data.azurerm_client_config.current.tenant_id
        object_id = azurerm_user_assigned_identity.uai.principal_id

    key_permissions = [
          "Get",
          "List",
          "Update",
          "Create",
          "Import",
          "Delete",
          "Recover",
          "Backup",
          "Restore",
          "GetRotationPolicy",
          "SetRotationPolicy",
          "Rotate",
        ]

        secret_permissions = [
          "Get",
          "List",
          "Set",
          "Delete",
          "Recover",
          "Backup",
          "Restore",
        ]
}

resource "azurerm_key_vault_access_policy"   "mistral_policy" {
        key_vault_id = azurerm_key_vault.kv.id
        tenant_id = data.azurerm_client_config.current.tenant_id
        object_id = module.mistral_ai_project.managed_identity_id

        secret_permissions = [
          "Get",
          "List",
        ]
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