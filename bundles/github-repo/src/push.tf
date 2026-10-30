locals {
  push_policy_arn = one([for p in var.registry.policies : p.arn if p.name == "push"])
}

resource "aws_iam_role" "push" {
  name = "${local.name}-push"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = var.github_oidc.provider_arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      # Repositories get either the classic subject or GitHub's immutable one,
      # which pins the repository's numeric ID so a renamed or recreated
      # repository can't inherit the role.
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = [
            "repo:${local.full_name}:ref:refs/heads/${var.default_branch}",
            "repo:${var.github.owner}@*/${var.repository_name}@${github_repository.main.repo_id}:ref:refs/heads/${var.default_branch}",
          ]
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "push" {
  role       = aws_iam_role.push.name
  policy_arn = local.push_policy_arn
}

resource "github_actions_variable" "push" {
  for_each = {
    AWS_REGION       = var.registry.region
    AWS_ROLE_ARN     = aws_iam_role.push.arn
    IMAGE_REPOSITORY = var.registry.url
  }

  repository    = github_repository.main.name
  variable_name = each.key
  value         = each.value
}
