resource "massdriver_resource" "project" {
  field = "project"
  name  = "Project ${var.project_name}"
  resource = jsonencode({
    id                  = massdriver_project.main.id
    identifier          = massdriver_project.main.identifier
    name                = var.project_name
    attributes          = local.attributes
    deploy_group_id     = massdriver_group.deploy.id
    deploy_environments = var.deploy_environments
    environments = [for e in var.environments : {
      id         = "${var.project_identifier}-${e.identifier}"
      identifier = e.identifier
      name       = e.name
    }]
  })

  depends_on = [massdriver_environment.main]
}
