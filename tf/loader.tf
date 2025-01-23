resource "azurerm_linux_function_app" "function_app_loader" {
  name                = "${local.resource_prefix}-dataloader-${local.environment}"
  resource_group_name = local.resource_group
  location            = azurerm_resource_group.kic_web_assistant_rg.location

  storage_account_name = azurerm_storage_account.kic_wa_sa.name
  service_plan_id      = azurerm_service_plan.streamlit_service_plan.id

  app_settings = {
    "ENVIRONMENT" = "PRODUCTION"
    "KEY_VAULT_NAME" = azurerm_key_vault.kv.name
    "FUNCTIONS_WORKER_RUNTIME" = "python"
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "DOCKER_CUSTOM_IMAGE_NAME" = "${azurerm_container_registry.kic_assistant.name}.azurecr.io/${var.loader_image_name}:1.7.3"
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.uai.id]
  }

  site_config {
    application_stack {
        docker {
            image_name = var.loader_image_name
            image_tag = "1.7.4"
            registry_url  = "https://${azurerm_container_registry.kic_assistant.login_server}"
        }
    }

    container_registry_use_managed_identity       = true
    container_registry_managed_identity_client_id = azurerm_user_assigned_identity.uai.client_id
  }
}