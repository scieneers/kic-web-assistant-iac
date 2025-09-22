terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.18.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = "~> 0.5"
    }
  }  
   backend "azurerm" {
   }
}


provider "azurerm" {
  features {}
  subscription_id = "9d1d3b6f-59c4-413e-b7f9-baa4d4af8b4a"
}

data "azurerm_client_config" "current" {}

