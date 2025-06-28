output "custom_domain_verification_id" {
  description = "The custom domain verification ID for the Container App."
  value       = azapi_resource.container_app.output.properties.customDomainVerificationId
}

output "fqdn_url" {
  description = "https url that contains ingress's fqdn, could be used to access the deployed app."
  value       = try("https://${azapi_resource.container_app.output.properties.configuration.ingress.fqdn}", "")
}

output "identity" {
  description = "The identities assigned to the Container App."
  value       = azapi_resource.container_app.output.identity
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
