data "cloudflare_zone" "bowmans_site" {
  zone_id = "469677242a458fb6aa0384da3becf086"
}

resource "cloudflare_dns_record" "record" {
  for_each        = { for record_key, record in local.records : record_key => record if record.cf_enabled }
  zone_id         = data.cloudflare_zone.bowmans_site.zone_id
  name            = each.value.hostname
  type            = "A"
  comment         = try(each.value.description, each.value.hostname)
  content         = each.value.public_ip
  proxied         = each.value.cf_proxy_enabled
}
resource "cloudflare_dns_record" "alias" {
  for_each        = { for alias_key, alias in local.aliases : alias_key => alias if alias.cf_enabled }
  zone_id         = data.cloudflare_zone.bowmans_site.zone_id
  name            = each.value.hostname
  type            = "CNAME"
  comment         = try(each.value.description, each.value.hostname)
  content         = "${cloudflare_dns_record.record[each.value.alias_of].name}.${cloudflare_dns_record.record[each.value.alias_of].domain}"
  proxied         = each.value.cf_proxy_enabled
}