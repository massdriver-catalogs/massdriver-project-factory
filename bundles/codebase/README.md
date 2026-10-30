# Codebase

Where an application's code lives and where its images go, as one resource: the Git repository and the container registry the factory made for it.

## Why one resource

The application's project needs both, in every environment, in every bundle that builds or runs the application. Two separate links across projects would be set per instance, and a new environment would start without them. One resource, set once as each environment's default, reaches every bundle there, and a bundle that only needs the registry takes the codebase and ignores the rest.

Bundles in the application's project read it as `azure-codebase`. A service assigns its own identity AcrPull on `registry.id` and runs `registry.login_server/<repository name>:<git-sha>`; a bundle that opens issues or reads the code uses `repository`.

## How it connects

It takes the factory's three other components: the repository, the container registry and the Massdriver project. It needs no cloud access of its own.

With **Share with the project** on, the codebase is shared with every environment whose `md-project` is the application's project, so people working there can pick it as a default without access to the factory. Setting it as the default is still a step per environment, because Massdriver's Terraform provider can't set environment defaults yet:

```bash
mass environment default <project>-<environment> <codebase resource ID>
```

## The project field

The resource type has a `project` field, commented out. Bundles that consume a codebase already run in the project it was made for, so carrying the project too would add a second source of truth that can disagree with where the bundle actually is. Uncomment it in the `azure-codebase` resource type and in this bundle's `src/main.tf` if bundles need the project's identifier or environment list.

## Decommissioning

Decommissioning deletes the codebase and stops sharing it. Environments that have it as their default lose that default; the repository and container registry are untouched.
