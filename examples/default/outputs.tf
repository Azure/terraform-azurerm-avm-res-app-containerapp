# output "latest_revision_fqdn" {
#   value = module.dashboard.latest_revision_fqdn
# }
#
# output "latest_revision_name" {
#   value = module.dashboard.latest_revision_name
# }
output "dashboard_url" {
  value = module.dashboard.fqdn_url
}
