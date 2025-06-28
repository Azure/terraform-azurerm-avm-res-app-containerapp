output "test_app_url" {
  value = "https://${module.container_app.fqdn_url}"
}
