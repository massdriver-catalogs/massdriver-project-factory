resource "massdriver_group" "catalog_publishers" {
  count       = var.catalog_publishers == null ? 0 : 1
  name        = var.catalog_publishers.group
  description = "Publishes the catalog from GitHub Actions."
}

resource "massdriver_group_policy" "catalog_publishers" {
  count      = var.catalog_publishers == null ? 0 : 1
  group_id   = massdriver_group.catalog_publishers[0].id
  effect     = "ALLOW"
  actions    = ["repo:create", "repo:push", "repo:pull", "repo:update", "repo:view"]
  conditions = "*"
}

resource "massdriver_service_account" "catalog_publisher" {
  count                    = var.catalog_publishers == null ? 0 : 1
  name                     = var.catalog_publishers.service_account
  description              = "GitHub Actions publishing the catalog."
  token_expiration_minutes = var.token_expiration_minutes
}

resource "massdriver_service_account_group_membership" "catalog_publisher" {
  count              = var.catalog_publishers == null ? 0 : 1
  group_id           = massdriver_group.catalog_publishers[0].id
  service_account_id = massdriver_service_account.catalog_publisher[0].id
}

resource "massdriver_project" "factory" {
  identifier  = var.factory.identifier
  name        = var.factory.name
  description = var.factory.description
  attributes  = var.factory.attributes
}

resource "massdriver_environment" "application" {
  for_each = var.applications

  project_id = massdriver_project.factory.id
  identifier = each.key
  name       = each.value.name
  attributes = each.value.attributes
}
