output "name" {
  description = "The name of the Container App AuthConfig resource."
  value       = azapi_resource.this.name
}

output "resource" {
  description = "The Container App AuthConfig azapi_resource that this submodule manages."
  value       = azapi_resource.this
}

output "resource_id" {
  description = "The Azure resource ID of the Container App AuthConfig created by this submodule."
  value       = azapi_resource.this.id
}
