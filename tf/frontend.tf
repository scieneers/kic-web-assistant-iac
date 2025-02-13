resource "azurerm_service_plan" "streamlit_service_plan" {
  name                = "${local.resource_prefix}asp${local.environment}"
  resource_group_name = azurerm_resource_group.kic_web_assistant_rg.name
  location            = azurerm_resource_group.kic_web_assistant_rg.location
  os_type             = "Linux"
  sku_name            = var.environment_short == "prod" ? "P1v3" : "P0v3"
}

resource "azurerm_linux_web_app" "streamlit_frontend" {
  name                = "${local.frontend_domain_prefix}-${local.environment}"
  count               = var.environment_short == "prod" ? 0 : 1
  resource_group_name = azurerm_resource_group.kic_web_assistant_rg.name
  location            = azurerm_resource_group.kic_web_assistant_rg.location
  service_plan_id     = azurerm_service_plan.streamlit_service_plan.id

  app_settings = {
    KEY_VAULT_NAME = azurerm_key_vault.kv.name
    AZURE_CLIENT_ID = azurerm_user_assigned_identity.uai.client_id
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false
  }
  site_config {
    application_stack {
      docker_image_name   = var.frontend_image_name
      docker_registry_url = "https://${azurerm_container_registry.kic_assistant.login_server}"
    }
    container_registry_use_managed_identity       = true
    container_registry_managed_identity_client_id = azurerm_user_assigned_identity.uai.client_id
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.uai.id]
  }

  https_only = true

  auth_settings_v2 {
    auth_enabled           = true
    default_provider       = "aad"
    runtime_version        = "~1"
    unauthenticated_action = "RedirectToLoginPage"
    active_directory_v2 {
      client_id                   = data.sops_file.secrets.data["AD_APP_ID"]
      login_parameters            = {}
      tenant_auth_endpoint        = "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}"
      www_authentication_disabled = false
    }
    login {
      token_store_enabled = true
    }
  }

}