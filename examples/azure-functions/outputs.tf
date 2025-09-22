output "container_app_environment_id" {
  description = "The ID of the Container App Environment."
  value       = azurerm_container_app_environment.this.id
}

output "container_app_fqdn_url" {
  description = "The HTTPS URL of the Container App with ingress FQDN."
  value       = module.container_app.fqdn_url
}

output "container_app_latest_revision_fqdn" {
  description = "The FQDN of the latest revision of the Container App."
  value       = module.container_app.latest_revision_fqdn
}

output "resource_group_name" {
  description = "The name of the resource group."
  value       = azurerm_resource_group.this.name
}
