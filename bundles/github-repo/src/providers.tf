terraform {
  required_version = ">= 1.6"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
    massdriver = {
      source  = "massdriver-cloud/massdriver"
      version = "~> 2.4"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.13"
    }
  }
}

provider "github" {
  owner = var.github.owner
  app_auth {
    id              = var.github.app_id
    installation_id = var.github.installation_id
    pem_file        = var.github.private_key
  }
}

provider "azurerm" {
  features {}
  client_id       = var.azure_authentication.client_id
  client_secret   = var.azure_authentication.client_secret
  tenant_id       = var.azure_authentication.tenant_id
  subscription_id = var.azure_authentication.subscription_id
}

# Deployment tokens can't manage service accounts, so these resources use the
# credential's API key. The default provider stays on the deployment token.
provider "massdriver" {
  alias           = "admin"
  api_key         = var.massdriver.token
  organization_id = var.massdriver.organization_id
}
