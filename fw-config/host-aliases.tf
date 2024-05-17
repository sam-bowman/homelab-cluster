# ARGOCD ALIAS
resource "opnsense_unbound_host_alias" "ARGOCD" {
  override = opnsense_unbound_host_override.TRAEFIK.id

  enabled = true
  hostname = "argocd.homelab"
  domain = "bowmans.site"
  description = "ARGOCD"
}
# CONSUL ALIAS
resource "opnsense_unbound_host_alias" "CONSUL" {
  override = opnsense_unbound_host_override.TRAEFIK.id

  enabled = true
  hostname = "consul.homelab"
  domain = "bowmans.site"
  description = "CONSUL"
}
# GRAFANA ALIAS
resource "opnsense_unbound_host_alias" "GRAFANA" {
  override = opnsense_unbound_host_override.TRAEFIK.id

  enabled = true
  hostname = "grafana.homelab"
  domain = "bowmans.site"
  description = "GRAFANA"
}
# HEIMDALL ALIAS
resource "opnsense_unbound_host_alias" "HEIMDALL" {
  override = opnsense_unbound_host_override.TRAEFIK.id

  enabled = true
  hostname = "heimdall.homelab"
  domain = "bowmans.site"
  description = "HEIMDALL"
}
# VAULT ALIAS
resource "opnsense_unbound_host_alias" "VAULT" {
  override = opnsense_unbound_host_override.TRAEFIK.id

  enabled = true
  hostname = "vault.homelab"
  domain = "bowmans.site"
  description = "VAULT"
}
# TEMP ALIAS
resource "opnsense_unbound_host_alias" "TEMP" {
  override = opnsense_unbound_host_override.TRAEFIK.id

  enabled = true
  hostname = "temp.homelab"
  domain = "bowmans.site"
  description = "TEMP"
}