# Container Registry

One Azure Container Registry for one app, in a resource group of its own. A pipeline pushes images to it, and services in the same subscription run them.

## Access

The admin user is off. Access is a role on this registry: a pipeline's identity gets **AcrPush**, and a service that runs the image gets **AcrPull**, each assigned by the bundle that owns that identity. The registry resource carries its Azure resource ID for exactly that assignment.

## Name

Registry names are global across Azure, so the name is the instance's name with a short random suffix, e.g. `factorybillingregistryk3x9q2` for the instance `factory-billing-registry`. Images are `<login server>/<image>:<tag>`.

## Tier

**Basic** fits one app's images and history. **Standard** adds storage and throughput for busy pipelines. Moving between them is an in-place change. Retention of untagged images needs Premium, which this bundle leaves out: one app's registry rarely needs geo-replication or private endpoints, and Premium costs ten times Basic.

## Decommissioning

Decommissioning deletes the resource group, the registry and every image in it. Rebuild images from the source repository if you need them again.
