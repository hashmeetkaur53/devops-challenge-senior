terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}

  client_id       = "<Replace the value as per your Azure Subscription>"
  client_secret   = "<Replace the value as per your Azure Subscription>"
  tenant_id       = "<Replace the value as per your Azure Subscription>"
  subscription_id = "<Replace the value as per your Azure Subscription>"
}