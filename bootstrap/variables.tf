variable "factory" {
  description = "The factory project."
  type = object({
    identifier  = string
    name        = string
    description = optional(string)
    attributes  = optional(map(string), {})
  })
  default = {
    identifier  = "factory"
    name        = "Application Factory"
    description = "Mints each application's Massdriver project, GitHub repository and container registry. One environment per application."
  }
}

variable "applications" {
  description = "Factory environments, one per application, keyed by identifier. Attributes are environment attributes, e.g. application and team."
  type = map(object({
    name       = string
    attributes = optional(map(string), {})
  }))
  default = {}
}

variable "catalog_publishers" {
  description = "The group and service account GitHub Actions uses to publish the catalog. Leave null when publishing is already set up."
  type = object({
    group           = string
    service_account = string
  })
  default = null
}

variable "token_expiration_minutes" {
  description = "How long the catalog publisher's token stays valid. Changing it replaces the service account and its token."
  type        = number
  default     = 525600
}
