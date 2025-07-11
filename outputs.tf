output "custom_domain_verification_id" {
  description = "The custom domain verification ID for the Container App."
  sensitive   = true
  value       = azapi_resource.container_app.output.properties.customDomainVerificationId
}

output "custom_domains" {
  description = "The custom domains configured for the Container App."
  value       = try(azapi_resource.container_app.output.properties.configuration.ingress.customDomains, null)
}

output "environment_id" {
  description = "The ID of the Container App Environment."
  value       = var.container_app_environment_resource_id
}

output "fqdn_url" {
  description = "https url that contains ingress's fqdn, could be used to access the deployed app."
  value       = try("https://${azapi_resource.container_app.output.properties.configuration.ingress.fqdn}", "")
}

output "identity" {
  description = "The identities assigned to the Container App."
  value       = azapi_resource.container_app.identity
}

output "latest_ready_revision_name" {
  description = "The name of the latest ready revision of the Container App."
  value       = azapi_resource.container_app.output.properties.latestReadyRevisionName
}

output "latest_revision_fqdn" {
  description = "The FQDN of the latest revision of the Container App."
  value       = try("https://${azapi_resource.container_app.output.properties.latestRevisionFqdn}", "")
}

output "latest_revision_name" {
  description = "The name of the latest revision of the Container App."
  value       = azapi_resource.container_app.output.properties.latestRevisionName
}

output "location" {
  description = "The Azure Region where the Container App is located."
  value       = azapi_resource.container_app.location
}

output "name" {
  description = "The name of the Container App."
  value       = azapi_resource.container_app.name
}

output "outbound_ip_addresses" {
  description = "The outbound IP addresses of the Container App."
  value       = azapi_resource.container_app.output.properties.outboundIpAddresses
}

output "resource_id" {
  description = "Resource ID of container app resource created by this module."
  value       = azapi_resource.container_app.id
}
