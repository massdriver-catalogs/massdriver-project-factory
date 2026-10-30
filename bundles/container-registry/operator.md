---
templating: mustache
---
# Container Registry

{{#resources.registry}}
## List what's there

```bash
az acr repository list --name {{resources.registry.name}} --output table
az acr repository show-tags --name {{resources.registry.name}} --repository <image> --orderby time_desc --top 10
```

## Push denied

- **`unauthorized: authentication required`:** log in first; tokens last three hours.

  ```bash
  az acr login --name {{resources.registry.name}}
  ```

- **Still denied:** the pusher's identity has no AcrPush role on this registry:

  ```bash
  az role assignment list --scope {{resources.registry.id}} --output table
  ```

## Image not found

```bash
az acr manifest list-metadata --registry {{resources.registry.name}} --name <image> --output table
```

- **No such image:** it was never pushed. Check the pipeline run.
- **It exists:** the service's identity has no AcrPull role on this registry, or it runs on a different CPU architecture than the image.

## Running out of space

```bash
az acr show-usage --name {{resources.registry.name}} --output table
```

Delete old images, or move to **Standard** and redeploy.
{{/resources.registry}}
