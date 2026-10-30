# Bootstrap

The factory project, an environment per application, and the factory's canvas, linked, from one `terraform apply`.

## Before you start

- The catalog is published to your Massdriver organization.
- The attributes you tag with are defined in the organization, or apply fails on them.
- An Organization Admin key.

## Run it

```bash
export MASSDRIVER_API_KEY=...
export MASSDRIVER_ORGANIZATION_ID=...
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform apply
```

## What you get

| What | Default |
|---|---|
| The factory project | Application Factory (`factory`) |
| One environment per entry in `applications` | none |
| Image Repository, Massdriver Project, Source Repository and Codebase on the canvas, linked | |
| *Optional:* group that publishes the catalog, and its service account | set `catalog_publishers` |

## What it leaves to you

Environment defaults, because the Terraform provider can't set them. On each factory environment, set the **AWS IAM Role**, **GitHub App**, **Massdriver Service Account** and the platform's **GitHub Actions OIDC** resource as defaults:

```bash
mass environment default factory-<application> <resource-id>
```

Then fill each instance's form and deploy the environment: the Massdriver Project first, then the Image Repository, the Source Repository and the Codebase.

Tokens end up in the state file, so keep the state somewhere private.
