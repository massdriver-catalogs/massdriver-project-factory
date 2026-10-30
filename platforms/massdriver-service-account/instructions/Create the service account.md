# Create the service account

The factory uses this service account to create each application's Massdriver project and environments, a group scoped to that project, and a service account for the application's pipeline in that group.

## 1. Create the service account

1. Open **Settings → Service Accounts → Create service account** and name it e.g. `Project Factory`, with a token that lasts **1 year**.
2. Copy the token. Massdriver shows it only once.

## 2. Make it an organization admin

Add the service account to the **Organization Admin** group.

It creates projects, groups and group policies, adds service accounts to groups, and shares resources with the projects it creates. Writing group policies is already admin-equal, since a group that can write policies can grant itself anything, so a narrower group buys nothing.

Paste your organization ID into **Organization ID** and the token into **Token**.
