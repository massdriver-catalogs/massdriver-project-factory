locals {
  attributes = { for k, v in {
    "project-type" = var.project_type
    "team"         = var.team
    "application"  = var.tag_application ? var.project_identifier : ""
  } : k => v if v != "" }

  environments = { for e in var.environments : e.identifier => e }
}

resource "massdriver_project" "main" {
  provider    = massdriver.admin
  identifier  = var.project_identifier
  name        = var.project_name
  description = var.description
  attributes  = local.attributes
}

resource "massdriver_environment" "main" {
  for_each = local.environments
  provider = massdriver.admin

  project_id              = massdriver_project.main.id
  identifier              = each.key
  name                    = each.value.name
  separation_of_duty      = coalesce(each.value.separation_of_duty, false)
  decommission_protection = coalesce(each.value.decommission_protection, false)

  lifecycle {
    precondition {
      condition     = length(local.environments) == length(var.environments)
      error_message = "Two environments share an identifier."
    }
  }
}

resource "massdriver_group" "deploy" {
  provider    = massdriver.admin
  name        = "${var.project_name} Deployers"
  description = "Views ${var.project_name} and deploys in ${length(var.deploy_environments) > 0 ? join(", ", var.deploy_environments) : "none of its environments"}."
}

# Projects carry no md-environment, so viewing gets its own policy; one
# condition set across both actions would never match the project.
resource "massdriver_group_policy" "view" {
  provider   = massdriver.admin
  group_id   = massdriver_group.deploy.id
  effect     = "ALLOW"
  actions    = ["project:view"]
  conditions = jsonencode({ md-project = [var.project_identifier] })
}

resource "massdriver_group_policy" "deploy" {
  count      = length(var.deploy_environments) > 0 ? 1 : 0
  provider   = massdriver.admin
  group_id   = massdriver_group.deploy.id
  effect     = "ALLOW"
  actions    = ["instance:deploy"]
  conditions = jsonencode({ md-project = [var.project_identifier], md-environment = var.deploy_environments })

  lifecycle {
    precondition {
      condition     = alltrue([for e in var.deploy_environments : contains(keys(local.environments), e)])
      error_message = "Pipeline deploys to names an environment that isn't in Environments."
    }
  }
}
