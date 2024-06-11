output "fqdn" {
  value = try("https://${azurerm_container_app.this.ingress[0].fqdn}", "")
}