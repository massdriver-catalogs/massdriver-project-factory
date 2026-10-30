---
templating: mustache
---
# Massdriver Project

{{#resources.project}}
## Set the environments' defaults

A new environment has no defaults, so its first deploy fails on missing credentials. Find each resource's ID, then set it on every environment:

```bash
mass resource list --type aws-iam-role
mass resource list --type aws-codebase
{{#resources.project.environments}}
mass environment default {{id}} <resource-id>
{{/resources.project.environments}}
```

## The pipeline can't deploy

The pipeline's service account must be in the deploy group, `{{resources.project.deploy_group_id}}` (**Settings → Groups**), and the instance must be in one of **Pipeline deploys to**. To let it deploy somewhere else, add that environment there and redeploy.
{{/resources.project}}

## Deploy fails: identifier already taken

Another project already uses **{{params.project_identifier}}**. Identifiers are unique in the organization. Pick another, or import the existing project into this instance's state.

## Deploy fails on an attribute

`unknown attribute` or `missing required attribute`: the organization's attribute settings don't match what this project sets. Define the key in the organization's attribute settings, or clear the field so the attribute isn't set.

## Removing an environment fails

The environment still has deployed instances. Decommission it in Massdriver, then redeploy this instance.
