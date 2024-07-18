resource "azurerm_container_app_environment" "qdrant-env" {
  name                       = "qdrant-environment"
  location                   = azurerm_resource_group.kic_web_assistant_rg.location
  resource_group_name        = azurerm_resource_group.kic_web_assistant_rg.name
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