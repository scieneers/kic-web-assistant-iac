# resource "azuread_application" "kicapp" {
#   display_name = "KI Campus App - ${local.environment}"
#   owners       = [data.azurerm_client_config.current.object_id]
# }

resource "azurerm_user_assigned_identity" "uai" {
  name                = "${var.resource_prefix}-uai-${local.environment}"
  resource_group_name = azurerm_resource_group.kic_web_assistant_rg.name
  location            = azurerm_resource_group.kic_web_assistant_rg.location
}

resource "azurerm_role_assignment" "aks_sp_acr" {
  scope                = azurerm_container_registry.kic_assistant.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.uai.principal_id
}