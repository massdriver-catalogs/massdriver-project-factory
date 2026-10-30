terraform {
  required_version = ">= 1.6"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    massdriver = {
      source  = "massdriver-cloud/massdriver"
      version = "~> 2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  client_id       = var.azure_authentication.client_id
  client_secret   = var.azure_authentication.client_secret
  tenant_id       = var.azure_authentication.tenant_id
  subscription_id = var.azure_authentication.subscription_id
}
