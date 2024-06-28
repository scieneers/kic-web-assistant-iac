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
      storage_account_name = "passed through cli"
      container_name       = "tfstate"
      key                  = "terraform.tfstate"
  }

}



provider "azurerm" {
  features {}
  #subscription_id = "134ef553-2dd7-40f4-bc9e-5fc3e8719757"
}

data "azurerm_client_config" "current" {}

