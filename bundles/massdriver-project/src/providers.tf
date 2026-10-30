terraform {
  required_version = ">= 1.6"
  required_providers {
    massdriver = {
      source  = "massdriver-cloud/massdriver"
      version = "~> 2.4"
    }
  }
}

# Deployment tokens can't manage projects, groups or service accounts, so these
# resources use the credential's API key. The default provider stays on the
# deployment token, which the bundle's own resource needs.
provider "massdriver" {
  alias           = "admin"
  api_key         = var.massdriver.token
  organization_id = var.massdriver.organization_id
}
