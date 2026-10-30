resource "azurerm_user_assigned_identity" "push" {
  name                = "${local.name}-push"
  resource_group_name = var.registry.resource_group_name
  location            = var.registry.location
  tags                = var.md_metadata.default_tags
}

resource "azurerm_role_assignment" "push" {
  scope                = var.registry.id
  role_definition_name = "AcrPush"
  principal_id         = azurerm_user_assigned_identity.push.principal_id
}

# Entra matches the subject exactly, so only the default branch of this
# repository can sign in as the identity. A renamed repository needs a redeploy.
resource "azurerm_federated_identity_credential" "push" {
  name                = "github-${replace(var.repository_name, ".", "-")}"
  resource_group_name = var.registry.resource_group_name
  parent_id           = azurerm_user_assigned_identity.push.id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = "https://token.actions.githubusercontent.com"
  subject             = "repo:${github_repository.main.full_name}:ref:refs/heads/${var.default_branch}"
}

resource "github_actions_variable" "push" {
  for_each = {
    AZURE_CLIENT_ID       = azurerm_user_assigned_identity.push.client_id
    AZURE_TENANT_ID       = azurerm_user_assigned_identity.push.tenant_id
    AZURE_SUBSCRIPTION_ID = var.azure_authentication.subscription_id
    REGISTRY_NAME         = var.registry.name
    IMAGE_REPOSITORY      = "${var.registry.login_server}/${lower(var.repository_name)}"
  }

  repository    = github_repository.main.name
  variable_name = each.key
  value         = each.value
}
