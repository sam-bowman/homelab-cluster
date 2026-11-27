data "cloudflare_zone" "bowmans_site" {
  zone_id = "6cdcf78c6b27e9e8b8bb8f8cb758abca"
}

locals {
  # Cloudflare stores and returns the full record name, so give it the full name too. A short name
  # ("adguard") made every plan show a change back from "adguard.bowmans.site".
  cf_zone_name = data.cloudflare_zone.bowmans_site.name
}

resource "cloudflare_dns_record" "record" {
  for_each        = { for record_key, record in local.records : record_key => record if record.cf_enabled }
  zone_id         = data.cloudflare_zone.bowmans_site.zone_id
  name            = "${replace(lower(each.value.hostname),".","-")}.${local.cf_zone_name}"
  type            = each.value.cf_record_type
  comment         = try(each.value.description, each.value.hostname)
  content         = each.value.cf_content
  proxied         = each.value.cf_proxy_enabled
  ttl             = 1
}
resource "cloudflare_dns_record" "alias" {
  for_each        = { for alias_key, alias in local.aliases : alias_key => alias if alias.cf_enabled }
  zone_id         = data.cloudflare_zone.bowmans_site.zone_id
  name            = "${replace(lower(each.value.hostname),".","-")}.${local.cf_zone_name}"
  type            = "CNAME"
  comment         = try(each.value.description, each.value.hostname)
  # The target record's name is already the full name.
  content         = try(each.value.cf_content, cloudflare_dns_record.record[each.value.alias_of].name)
  proxied         = each.value.cf_proxy_enabled
  ttl             = 1
}
