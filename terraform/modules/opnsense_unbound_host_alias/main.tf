resource "opnsense_unbound_host_alias" "host_alias" {
  override          = var.host_override_id
  enabled           = var.enabled
  description       = var.description != null ? var.description : var.hostname
  hostname          = var.hostname
  domain            = var.domain
}