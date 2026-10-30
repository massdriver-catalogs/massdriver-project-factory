---
templating: mustache
---
# Codebase

{{#dependencies.project}}
## Set it as the project's default

Sharing makes the codebase visible to the project; each environment still needs it as its default.

```bash
mass resource list --type aws-codebase --search "{{dependencies.repository.full_name}}"
{{#dependencies.project.environments}}
mass environment default {{id}} <codebase-resource-id>
{{/dependencies.project.environments}}
```
{{/dependencies.project}}

## A bundle in the project can't see the codebase

- **Not shared:** **Share with the project** is off. Turn it on and redeploy.
- **Shared, but the environment isn't in the project:** the grant matches `md-project = {{dependencies.project.identifier}}`. Environments of other projects can't use it.
- **Shared, but not the default:** set it as the environment's default, above.

## Deploy fails sharing the resource

The Massdriver Service Account credential can't share resources. It needs `resource:grant`; the credential's instructions put it in Organization Admin, which has it.
