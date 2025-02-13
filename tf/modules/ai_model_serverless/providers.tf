terraform {
  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~>1.8.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.18.0"
    }
  }
}