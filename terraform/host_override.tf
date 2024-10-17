module "override" {
  source            = "github.com/sam-bowman/homelab-cluster/terraform/modules/opnsense_unbound_host_override"
  for_each          = local.overrides

  hostname          = each.hostname
  domain            = each.domain
  aliases           = try(each.aliases, {})
}