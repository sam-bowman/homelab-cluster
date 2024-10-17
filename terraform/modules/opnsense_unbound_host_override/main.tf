resource "opnsense_unbound_host_override" "host_override" {
  enabled           = var.enabled
  description       = var.description
  hostname          = var.hostname
  domain            = var.domain
  server            = var.ip
}