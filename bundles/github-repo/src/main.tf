locals {
  name      = var.md_metadata.name_prefix
  full_name = "${var.github.owner}/${var.repository_name}"
  workflows = var.add_workflows && !var.adopt_existing_repository
}

resource "github_repository" "main" {
  name                   = var.repository_name
  description            = var.description
  visibility             = var.visibility
  auto_init              = true
  has_issues             = true
  delete_branch_on_merge = true

  # Decommissioning archives the repository instead of deleting the code.
  archive_on_destroy = true

  lifecycle {
    # auto_init only matters when GitHub creates the repository. An adopted one
    # reads back without it, and acting on that diff would replace the repository.
    ignore_changes = [auto_init]
  }
}

resource "github_repository_vulnerability_alerts" "main" {
  repository = github_repository.main.name
  enabled    = true
}

# auto_init creates main; any other default branch is cut from it.
resource "github_branch" "default" {
  count      = var.default_branch == "main" ? 0 : 1
  repository = github_repository.main.name
  branch     = var.default_branch
}

resource "github_branch_default" "main" {
  repository = github_repository.main.name
  branch     = var.default_branch
  depends_on = [github_branch.default]
}

# Written once; after the first commit the team owns these files. The
# variables and secret go first so the first run already has them.
resource "github_repository_file" "workflow" {
  for_each = local.workflows ? {
    "build.yml"   = templatefile("${path.module}/workflows/build.yml.tftpl", { branch = var.default_branch, platform = var.image_platform })
    "release.yml" = templatefile("${path.module}/workflows/release.yml.tftpl", { branch = var.default_branch, mass_version = "2.5.0" })
  } : {}

  repository          = github_repository.main.name
  branch              = var.default_branch
  file                = ".github/workflows/${each.key}"
  content             = each.value
  commit_message      = "Add the ${each.key} workflow"
  overwrite_on_create = false

  lifecycle {
    ignore_changes = [content, commit_message, commit_author, commit_email]
  }

  depends_on = [
    github_branch_default.main,
    github_actions_variable.push,
    github_actions_variable.massdriver,
    github_actions_secret.massdriver,
  ]
}
