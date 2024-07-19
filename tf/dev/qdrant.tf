resource "azurerm_container_app_environment" "qdrant-env" {
  name                       = "qdrant-environment"
  location                   = azurerm_resource_group.kic_web_assistant_rg.location
  resource_group_name        = azurerm_resource_group.kic_web_assistant_rg.name
 }

resource "azurerm_container_app_environment_storage" "qdrant-storage" {

  name                         = "qdrant-storage"
  container_app_environment_id = azurerm_container_app_environment.qdrant-env.id
  account_name                 = azurerm_storage_account.kic_wa_sa.name
  share_name                   = azurerm_storage_share.share.name
  access_key                   = azurerm_storage_account.kic_wa_sa.primary_access_key
  access_mode                  = "ReadWrite"
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
            name = "QDRANT__SERVICE__API_KEY"
            value = data.sops_file.secrets.data["qdrant_api_key"]
        }

      volume_mounts {
        name = "qdrant-data"
        path = "/qdrant/storage"
      }
    }

    volume {
      name = "qdrant-data"
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
    target_port = 6333
    transport        = "auto"
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}