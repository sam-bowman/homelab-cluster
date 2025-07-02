module "host_override" {
  source            = "github.com/sam-bowman/homelab-cluster/terraform/modules/opnsense_unbound_host_override"
  for_each          = local.records

  hostname          = each.value.hostname
  domain            = try(each.value.domain, local.default_domain)
  ip                = each.value.ip
}

module "host_alias" {
  source            = "github.com/sam-bowman/homelab-cluster/terraform/modules/opnsense_unbound_host_alias"
  for_each          = local.aliases

  host_override_id  = module.host_override[each.value.alias_of].id
  enabled           = try(each.value.enabled, null)
  description       = try(each.value.description, each.value.hostname)
  hostname          = each.value.hostname
  domain            = try(each.value.domain, module.host_override[each.value.alias_of].domain)
}