resource "azurerm_container_registry" "kic_assistant" {
  name                = "kicchatassistantacr" # TODO: change to "${var.resource_prefix}acr${local.environment}" 
  resource_group_name = azurerm_resource_group.kic_web_assistant_rg.name
  location            = azurerm_resource_group.kic_web_assistant_rg.location
  sku                 = "Basic"
}