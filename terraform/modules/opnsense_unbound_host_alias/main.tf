resource "opnsense_unbound_host_alias" "host_alias" {
  override        = var.host_override_id
  enabled         = var.enabled
  description     = var.description
  hostname        = var.hostname
  domain          = var.domain
}