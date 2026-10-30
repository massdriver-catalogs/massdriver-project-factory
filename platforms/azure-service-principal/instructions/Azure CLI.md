# Connect your Azure subscription with the Azure CLI

Massdriver deploys into your subscription as a service principal you create. Run this from a machine with the Azure CLI, not Cloud Shell, which can't grant the role below.

## 1. Pick the subscription

```bash
az account list --output table
SUBSCRIPTION_ID=<subscription-id>
```

Paste the subscription's ID into **Subscription ID** and its tenant ID into **Tenant ID**.

## 2. Create the service principal

The same service principal deploys the factory and the applications it mints. It creates resources and assigns roles on them, such as a pipeline's push access to its registry, so it needs the Owner role.

```bash
az ad sp create-for-rbac --name massdriver \
  --role Owner \
  --scopes "/subscriptions/$SUBSCRIPTION_ID"
```

Paste `appId` into **Client ID** and `password` into **Client Secret**.
