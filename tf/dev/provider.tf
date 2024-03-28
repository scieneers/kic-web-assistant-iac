provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "kic_web_assistant_rg" {
  name     = var.resource_group
  location = var.region
}

resource "azurerm_storage_account" "kic_wa_sa" {
  name                     = "kicwasa"
  resource_group_name      = azurerm_resource_group.kic_web_assistant_rg.name
  location                 = azurerm_resource_group.kic_web_assistant_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "sc" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.kic_wa_sa.name
  container_access_type = "private"
}