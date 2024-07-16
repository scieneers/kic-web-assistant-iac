terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.95.0"
    }
    sops = {
      source = "carlpett/sops"
      version = "~> 0.5"
    }
  }
  backend "azurerm" {
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    resource_group_name  = "kic-chat-assistant_dev"
    storage_account_name = "kicwastadev"
    tenant_id            = "c6ff58bc-993e-4bdb-8d10-6013e2cd361f"
    subscription_id      = "134ef553-2dd7-40f4-bc9e-5fc3e8719757"
  }
}


provider "azurerm" {
  features {}
  #subscription_id = "134ef553-2dd7-40f4-bc9e-5fc3e8719757"
}

data "azurerm_client_config" "current" {}

