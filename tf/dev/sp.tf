data "azurerm_client_config" "current" {}


resource "azuread_application" "kicapp" {
  display_name = "KI Campus App"
  owners       = [data.azurerm_client_config.current.object_id]
}

resource "azuread_service_principal" "kic_k8s_service_principal" {
  client_id = azuread_application.kicapp.client_id
  owners    = [data.azurerm_client_config.current.object_id]
}

resource "azuread_service_principal_password" "kic_k8s_service_principal_pw" {
  service_principal_id = azuread_service_principal.kic_k8s_service_principal.object_id
}

resource "azurerm_role_assignment" "aks_sp_acr" {
  scope                = azurerm_container_registry.kic_assistant.id
  role_definition_name = "AcrPull"
  principal_id         = azuread_service_principal.kic_k8s_service_principal.object_id
}