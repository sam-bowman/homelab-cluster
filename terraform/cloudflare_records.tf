data "cloudflare_zone" "bowmans_site" {
  zone_id = "6cdcf78c6b27e9e8b8bb8f8cb758abca"
}

resource "cloudflare_dns_record" "record" {
  for_each        = { for record_key, record in local.records : record_key => record if record.cf_enabled }
  zone_id         = data.cloudflare_zone.bowmans_site.zone_id
  name            = "${replace(lower(each.value.hostname),".","-")}"
  type            = each.value.cf_record_type
  comment         = try(each.value.description, each.value.hostname)
  content         = each.value.cf_content
  proxied         = each.value.cf_proxy_enabled
  ttl             = 1
}
resource "cloudflare_dns_record" "alias" {
  for_each        = { for alias_key, alias in local.aliases : alias_key => alias if alias.cf_enabled }
  zone_id         = data.cloudflare_zone.bowmans_site.zone_id
  name            = "${replace(lower(each.value.hostname),".","-")}"
  type            = "CNAME"
  comment         = try(each.value.description, each.value.hostname)
  content         = coalesce(each.value.cf_content, "${replace(lower(cloudflare_dns_record.record[each.value.alias_of].name),".","-")}.${data.cloudflare_zone.bowmans_site.name}")
  proxied         = each.value.cf_proxy_enabled
  ttl             = 1
}