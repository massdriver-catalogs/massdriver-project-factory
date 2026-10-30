output "catalog_publisher_token" {
  description = "Goes in the catalog repository's MASSDRIVER_API_KEY Actions secret."
  value       = one(massdriver_service_account.catalog_publisher[*].token)
  sensitive   = true
}

output "environments" {
  value = { for k, e in massdriver_environment.application : k => "${var.factory.identifier}-${k}" }
}
