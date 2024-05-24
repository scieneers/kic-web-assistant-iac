resource "azurerm_key_vault" "kv" {
  name                        = "${var.resource_prefix}-keyvault-${local.environment}"
  location                    = var.region
  resource_group_name         = var.resource_group
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"

  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  access_policy {
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
  access_policy {
        tenant_id = data.azurerm_client_config.current.tenant_id
        object_id = data.azurerm_client_config.current.object_id

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

    access_policy {
        tenant_id = data.azurerm_client_config.current.tenant_id
        object_id = azurerm_kubernetes_cluster.kic_k8s_cluster.kubelet_identity[0].object_id

        secret_permissions = [
          "Get",
          "List",
        ]
  }
}

resource "azurerm_key_vault_secret" "oauth2-cookie-secret" {
  name         = "oauth2-cookie-secret"
  value        = "ceb00cc4b2d9acc67980cc6e7f6de928"
  key_vault_id = azurerm_key_vault.kv.id

  ### Explicit dependency
  depends_on = [
    azurerm_key_vault.kv
  ]
}


resource "azurerm_key_vault_secret" "oauth2-proxy-client-id" {
  name         = "oauth2-proxy-client-id"
  value        = "d6c1c517-6b89-4c71-a4b5-bd7108e2476e"
  key_vault_id = azurerm_key_vault.kv.id

  ### Explicit dependency
  depends_on = [
    azurerm_key_vault.kv
  ]
}


resource "azurerm_key_vault_secret" "oauth2-proxy-client-secret" {
  name         = "oauth2-proxy-client-secret"
  value        = "Yh_8Q~Yfp9rUaNqGJwjXIgHXzdLsiWebkkYwmcqO"
  key_vault_id = azurerm_key_vault.kv.id

  ### Explicit dependency
  depends_on = [
    azurerm_key_vault.kv
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