resource "azurerm_container_app_environment" "qdrant-env" {
  name                = "qdrant-environment"
  location            = azurerm_resource_group.kic_web_assistant_rg.location
  resource_group_name = azurerm_resource_group.kic_web_assistant_rg.name
}

resource "azurerm_container_app_environment_storage" "qdrant-storage" {
  name                         = "qdrant-storage"
  container_app_environment_id = azurerm_container_app_environment.qdrant-env.id
  account_name                 = azurerm_storage_account.kic_wa_sa.name
  share_name                   = azurerm_storage_share.share.name
  access_key                   = azurerm_storage_account.kic_wa_sa.primary_access_key
  access_mode                  = "ReadWrite"
}

resource "random_password" "qdrant_api_key" {
  length  = 64
  special = false
}

module "key_vault_qdrant_api_key" {
  source       = "./modules/key_vault_secrets"
  key_vault_id = azurerm_key_vault.kv.id
  secrets = {
    QDRANT_API_KEY : random_password.qdrant_api_key.result
  }
}
resource "azurerm_container_app" "qdrant" {
  name                         = "qdrant-app"
  container_app_environment_id = azurerm_container_app_environment.qdrant-env.id
  resource_group_name          = azurerm_resource_group.kic_web_assistant_rg.name
  revision_mode                = "Single"

  template {
    container {
      name   = "qdrant"
      image  = "kicwaacrdev.azurecr.io/qdrant/qdrant:v1.10.1"
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name  = "QDRANT__SERVICE__API_KEY"
        value = module.key_vault_qdrant_api_key.secrets["QDRANT_API_KEY"]
      }

      volume_mounts {
        name = "qdrant-data"
        path = "/qdrant/storage"
      }
    }

    volume {
      name         = "qdrant-data"
      storage_name = azurerm_container_app_environment_storage.qdrant-storage.name
      storage_type = "AzureFile"
    }


  }
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.uai.id]
  }

  registry {
    server   = azurerm_container_registry.kic_assistant.login_server
    identity = azurerm_user_assigned_identity.uai.id
  }

  ingress {
    external_enabled = true
    target_port      = 6333
    transport        = "auto"
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}

module "key_vault_qdrant_url" {
  source       = "./modules/key_vault_secrets"
  key_vault_id = azurerm_key_vault.kv.id
  secrets = {
    QDRANT_URL : azurerm_container_app.qdrant.ingress[0].fqdn
  }
}