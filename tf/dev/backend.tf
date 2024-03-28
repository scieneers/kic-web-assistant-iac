terraform {
  backend "azurerm" {
    resource_group_name   = "kic-chat-assistant"
    storage_account_name  = "kicwasa"
    container_name        = "tfstate"
    key                   = "kic-chat-assistant.terraform.tfstate"
  }
}