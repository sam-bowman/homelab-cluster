resource "opnsense_unbound_host_override" "host_override" {
  enabled           = var.enabled
  description       = var.description != null ? var.description : var.hostname
  hostname          = var.hostname
  domain            = var.domain
  server            = var.ip
}

module "host_alias" {
  source            = "github.com/sam-bowman/homelab-cluster/terraform/modules/opnsense_unbound_host_alias"
  for_each          = var.aliases

  host_override_id  = opnsense_unbound_host_override.host_override.id
  enabled           = each.value.enabled
  description       = each.value.description != null ? each.value.description : each.value.hostname
  hostname          = each.value.hostname
  domain            = each.value.domain != null ? each.value.domain : var.hostname
}