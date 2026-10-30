locals {
  components = {
    registry = { bundle = "container-registry", name = "Container Registry" }
    project  = { bundle = "massdriver-project", name = "Massdriver Project" }
    repo     = { bundle = "github-repo", name = "Source Repository" }
    codebase = { bundle = "codebase", name = "Codebase" }
  }

  links = {
    repo_registry     = { from = "registry", from_field = "repository", to = "repo", to_field = "registry" }
    repo_project      = { from = "project", from_field = "project", to = "repo", to_field = "project" }
    codebase_registry = { from = "registry", from_field = "repository", to = "codebase", to_field = "registry" }
    codebase_repo     = { from = "repo", from_field = "repository", to = "codebase", to_field = "repository" }
    codebase_project  = { from = "project", from_field = "project", to = "codebase", to_field = "project" }
  }
}

resource "massdriver_component" "this" {
  for_each = local.components

  project_id  = massdriver_project.factory.id
  identifier  = each.key
  name        = each.value.name
  bundle_name = each.value.bundle
}

resource "massdriver_component_link" "this" {
  for_each = local.links

  from_component_id = massdriver_component.this[each.value.from].id
  from_field        = each.value.from_field
  to_component_id   = massdriver_component.this[each.value.to].id
  to_field          = each.value.to_field
}
