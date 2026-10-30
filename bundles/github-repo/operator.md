---
templating: mustache
---
# GitHub Repository

{{#resources.repository}}
## See recent runs

```bash
gh run list -R {{resources.repository.full_name}} --limit 10
gh run view -R {{resources.repository.full_name}} --log-failed
```
{{/resources.repository}}

## The build didn't push

- **No Dockerfile at the root:** only the secret scan runs until there is one.
- **Pull request or another branch:** only pushes to **{{params.default_branch}}** push images.
- **secrets job failed:** gitleaks found something that looks like a credential, in the current files or anywhere in history. Revoke the credential first; removing it from the code doesn't un-leak it. A false positive can be allowed with a `.gitleaksignore` entry holding the finding's fingerprint from the log.
- **Scan the image failed:** Trivy found a critical vulnerability with a fix available. Rebuilding usually pulls the patched base image; otherwise bump the base image tag.

## "Not authorized to perform sts:AssumeRoleWithWebIdentity"

The role only trusts `{{params.default_branch}}` of this repository. Builds from forks, tags or other branches can't assume it. If the repository was renamed or transferred, the trust no longer matches: redeploy this instance. If the job never got a token at all, the workflow is missing `permissions: id-token: write`.

## Push denied by ECR

- **`tag invalid` or `already exists`:** the ECR repository has immutable tags and this commit was already pushed. Push a new commit.
- **`not authorized to perform ecr:...`:** the role's push policy no longer matches the ECR repository. Redeploy this instance so it reattaches the current policy.

## The release didn't deploy

{{#resources.repository}}
```bash
gh run list -R {{resources.repository.full_name}} --workflow release.yml --limit 5
gh variable list -R {{resources.repository.full_name}}
```
{{/resources.repository}}

- **The deploy job was skipped:** `MASSDRIVER_RELEASE_INSTANCE` isn't set. Set **Release to environment** and **Release component** and redeploy.
- **"not authorized" or "forbidden":** the project's deploy group can't deploy in that environment. Add it to the Massdriver project's **Pipeline deploys to** and redeploy that instance.
- **Instance not found:** no component with that identifier is on the project's canvas, or the environment has no instance of it yet.
- **401 or "unauthenticated":** the pipeline's token expired; it lasts a year. Redeploy this instance: a token older than eleven months is replaced on deploy.

## Deploy fails: name already exists

Another repository in the organization, possibly an archived one from an earlier deploy, has the name **{{params.repository_name}}**. Delete or rename it on GitHub, or pick a different name.

## Deploy fails with 403 from GitHub

The GitHub App lacks a permission or isn't installed on all repositories. Check the app's permissions against the GitHub App credential's instructions, then **Install App → All repositories**.
