module "host_ovr" {
  source            = "github.com/sam-bowman/homelab-cluster/terraform/modules/opnsense_unbound_host_override"
  for_each          = local.overrides

  hostname          = each.value.hostname
  domain            = each.value.domain
  ip                = each.value.ip
  aliases           = try(each.value.aliases, {})
}