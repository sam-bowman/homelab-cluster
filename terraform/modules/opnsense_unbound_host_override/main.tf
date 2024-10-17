resource "opnsense_unbound_host_override" "host_override" {
  enabled           = var.enabled
  description       = var.description != null ? var.description : var.hostname
  hostname          = var.hostname
  domain            = var.domain
  server            = var.ip
}

module "aliases" {
  source            = "github.com/sam-bowman/homelab-cluster/terraform/modules/opnsense_unbound_host_alias"
  for_each          = var.aliases

  override          = opnsense_unbound_host_override.host_override.id
  enabled           = each.enabled
  description       = each.description != null ? each.description : each.hostname
  hostname          = each.hostname
  domain            = each.domain != null ? each.domain : var.hostname
}