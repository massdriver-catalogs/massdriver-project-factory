terraform {
  required_version = ">= 1.6"
  required_providers {
    massdriver = {
      source  = "massdriver-cloud/massdriver"
      version = "~> 2.4"
    }
  }
}

# Deployment tokens can't share resources, so the grant uses the credential's
# API key. The default provider stays on the deployment token.
provider "massdriver" {
  alias           = "admin"
  api_key         = var.massdriver.token
  organization_id = var.massdriver.organization_id
}
