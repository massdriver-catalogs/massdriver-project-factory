locals {
  name = var.md_metadata.name_prefix
  # Registry names are 5 to 50 letters and digits, unique across Azure.
  registry_name = substr("${replace(local.name, "/[^a-z0-9]/", "")}${random_string.suffix.result}", 0, 50)
}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "azurerm_resource_group" "main" {
  name     = local.name
  location = var.location
  tags     = var.md_metadata.default_tags
}

resource "azurerm_container_registry" "main" {
  name                = local.registry_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = var.sku

  # Pushes and pulls go through Entra identities with roles on this registry;
  # the shared admin password would bypass them.
  admin_enabled = false

  tags = var.md_metadata.default_tags
}

resource "massdriver_resource" "registry" {
  field = "registry"
  name  = "ACR ${azurerm_container_registry.main.name}"
  resource = jsonencode({
    id                  = azurerm_container_registry.main.id
    name                = azurerm_container_registry.main.name
    login_server        = azurerm_container_registry.main.login_server
    resource_group_name = azurerm_resource_group.main.name
    location            = var.location
  })
}
