# resource "azurerm_app_service_plan" "app_service_plan" {
#   name                = "${local.resource_prefix}fasp${local.environment}"
#   location            = azurerm_resource_group.kic_web_assistant_rg.location
#   resource_group_name = local.resource_group

#   sku {
#     tier = "Standard"
#     size = "S1"
#   }
# }

# resource "azurerm_function_app" "function_app_loader" {
#   name                       = "${local.resource_prefix}-dataloader-${local.environment}"
#   location                   = azurerm_resource_group.kic_web_assistant_rg.location
#   resource_group_name        = local.resource_group
# #  app_service_plan_id        = azurerm_app_service_plan.app_service_plan.id
#   app_service_plan_id        = azurerm_service_plan.streamlit_service_plan.id
#   storage_account_name       = azurerm_storage_account.kic_wa_sa.name
#   storage_account_access_key = azurerm_storage_account.kic_wa_sa.primary_access_key
# }

resource "azurerm_linux_function_app" "function_app_loader" {
  name                = "${local.resource_prefix}-dataloader-${local.environment}"
  resource_group_name = local.resource_group
  location            = azurerm_resource_group.kic_web_assistant_rg.location

  storage_account_name = azurerm_storage_account.kic_wa_sa.name
  service_plan_id      = azurerm_service_plan.streamlit_service_plan.id

  app_settings = {
  "ENVIRONMENT" = "PRODUCTION"
  "KEY_VAULT_NAME" = azurerm_key_vault.kv.name
  }

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
        docker {
            image_name = var.loader_image_name
            image_tag = "latest"
            registry_url  = "https://${azurerm_container_registry.kic_assistant.login_server}"
        }
    }
  }
}