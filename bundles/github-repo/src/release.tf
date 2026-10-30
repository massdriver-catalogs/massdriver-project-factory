locals {
  release_environment = var.release_environment == null ? "" : var.release_environment
  release_component   = var.release_component == null ? "" : var.release_component
  release             = local.release_environment != "" && local.release_component != ""
  massdriver_url      = try(regex("^https?://[^/]+", var.md_metadata.observability.alarm_webhook_url), "https://api.massdriver.cloud")
}

# Tokens can't be reissued for an existing service account, so rotation
# replaces it: the first deploy after this comes due makes a new one.
resource "time_rotating" "pipeline_token" {
  rotation_days = 330
}

resource "massdriver_service_account" "pipeline" {
  provider                 = massdriver.admin
  name                     = "${local.full_name} pipeline"
  description              = "Deploys ${local.full_name} builds into ${var.project.name}."
  token_expiration_minutes = 525600

  lifecycle {
    replace_triggered_by = [time_rotating.pipeline_token]
  }
}

resource "massdriver_service_account_group_membership" "pipeline" {
  provider           = massdriver.admin
  group_id           = var.project.deploy_group_id
  service_account_id = massdriver_service_account.pipeline.id
}

resource "github_actions_secret" "massdriver" {
  repository      = github_repository.main.name
  secret_name     = "MASSDRIVER_API_KEY"
  plaintext_value = massdriver_service_account.pipeline.token
}

# GitHub rejects empty variables, so the release ones exist only when a
# release target is set; the workflow skips its deploy without them.
resource "github_actions_variable" "massdriver" {
  for_each = merge(
    {
      MASSDRIVER_ORGANIZATION_ID = var.massdriver.organization_id
      MASSDRIVER_URL             = local.massdriver_url
      MASSDRIVER_PROJECT         = var.project.identifier
    },
    local.release ? {
      MASSDRIVER_RELEASE_INSTANCE = "${var.project.identifier}-${local.release_environment}-${local.release_component}"
      MASSDRIVER_IMAGE_FIELD      = coalesce(var.release_image_field, "image_uri")
    } : {},
  )

  repository    = github_repository.main.name
  variable_name = each.key
  value         = each.value

  lifecycle {
    precondition {
      condition     = local.release_environment == "" || contains(var.project.deploy_environments, local.release_environment)
      error_message = "The project's deploy group can't deploy in the release environment. Add it to the project's Pipeline deploys to, or pick another."
    }
  }
}
