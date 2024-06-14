output "fqdn_url" {
  description = "https url that contains ingress's fqdn, could be used to access the deployed app."
  value       = try("https://${azurerm_container_app.this.ingress[0].fqdn}", "")
}

output "resource" {
  description = "`azurerm_container_app` resource created by this module."
  value       = azurerm_container_app.this
}

output "resource_id" {
  description = "Resource ID of `azurerm_container_app` resource created by this module."
  value       = azurerm_container_app.this.id
}
