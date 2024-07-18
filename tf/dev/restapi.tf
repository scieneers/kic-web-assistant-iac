resource "azurerm_service_plan" "restapi" {
  name                = "${local.resource_prefix}-restapi-service-plan-${local.environment}"
  resource_group_name      = azurerm_resource_group.kic_web_assistant_rg.name
  location                 = azurerm_resource_group.kic_web_assistant_rg.location
  os_type             = "Linux"
  sku_name            = "B2"
}

resource "azurerm_linux_web_app" "restapi" {
  name                = "kic-restapi-${local.environment}"
  resource_group_name = azurerm_resource_group.kic_web_assistant_rg.name
  location            = azurerm_resource_group.kic_web_assistant_rg.location
  service_plan_id     = azurerm_service_plan.streamlit_service_plan.id

  site_config {
    application_stack {
      docker_image_name   = "rest-api:v1"
      docker_registry_url = "https://${azurerm_container_registry.kic_assistant.login_server}"
    }
    container_registry_use_managed_identity = true
    container_registry_managed_identity_client_id = azurerm_user_assigned_identity.uai.client_id
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.uai.id]
  }

  https_only = true
}