resource "azurerm_public_ip" "kicwa-pip" {
  name                = "${var.resource_prefix}-pip-${local.environment}"
  resource_group_name = azurerm_resource_group.kic_web_assistant_rg.name
  location            = azurerm_resource_group.kic_web_assistant_rg.location
  allocation_method   = "Static"
}

resource "azurerm_lb" "kicwa-lb" {
  name                = "${var.resource_prefix}-lb-${local.environment}"
  resource_group_name = azurerm_resource_group.kic_web_assistant_rg.name
  location            = azurerm_resource_group.kic_web_assistant_rg.location

  frontend_ip_configuration {
    name                 = "${var.resource_prefix}-pip-${local.environment}"
    public_ip_address_id = azurerm_public_ip.kicwa-pip.id
  }
}