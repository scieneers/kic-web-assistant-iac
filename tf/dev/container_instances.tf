resource "azurerm_container_group" "qdrant_container_group" {
  name                = "qdrant-aci"
  location            = azurerm_resource_group.kic_web_assistant_rg.location
  resource_group_name = azurerm_resource_group.kic_web_assistant_rg.name
  ip_address_type     = "Public"
  os_type             = "Linux"

  container {
    name   = "qdrant-container"
    image  = "qdrant/qdrant:master"
    cpu    = "4"
    memory = "1"

    ports {
      port     = 6333
      protocol = "TCP"
    }

    ports {
      port     = 6334
      protocol = "TCP"
    }


    secure_environment_variables = {
      QDRANT__SERVICE__API_KEY = data.sops_file.secrets.data["qdrant_api_key"]
    }

    volume {
      name = "qdrant-volume"
      storage_account_name = azurerm_storage_account.kic_wa_sa.name
      storage_account_key = azurerm_storage_account.kic_wa_sa.primary_access_key
      share_name = azurerm_storage_share.share.name
      mount_path = "/qdrant/storage"

  }

  }


}