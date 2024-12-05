resource "random_password" "restapi_key_moodle" {
  length  = 32
  special = true
  override_special = "$-_.+!*()"
}
resource "random_password" "restapi_key_scieneers" {
  length  = 32
  special = true
  override_special = "$-_.+!*()"
}

resource "random_password" "restapi_key_drupal" {
  length  = 32
  special = true
  override_special = "$-_.+!*()"
}


module "key_vault_restapi" {
  source       = "./modules/key_vault_secrets"
  key_vault_id = azurerm_key_vault.kv.id
  secrets = {
    # TODO: make this a loop, maybe the key-gen too...
    REST_API_KEYS : "['moodle-${random_password.restapi_key_moodle.result}', 'scieneers-${random_password.restapi_key_scieneers.result}', 'drupal-${random_password.restapi_key_drupal.result}']"
  }
}

resource "azurerm_service_plan" "restapi" {
  name                = "${local.resource_prefix}-restapi-service-plan-${local.environment}"
  resource_group_name = azurerm_resource_group.kic_web_assistant_rg.name
  location            = azurerm_resource_group.kic_web_assistant_rg.location
  os_type             = "Linux"
  sku_name            = "B2"
}

resource "azurerm_linux_web_app" "restapi" {
  name                = "kic-restapi-${local.environment}"
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
      docker_image_name   = "freddy/rest-api:1.7.2"
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
}