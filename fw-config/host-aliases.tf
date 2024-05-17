# ARGOCD
resource "opnsense_unbound_host_alias" "ARGOCD" {
  override = opnsense_unbound_host_override.TRAEFIK.id

  enabled = true
  hostname = "argocd.homelab"
  domain = "bowmans.site"
  description = "ARGOCD"
}
# CONSUL
resource "opnsense_unbound_host_alias" "CONSUL" {
  override = opnsense_unbound_host_override.TRAEFIK.id

  enabled = true
  hostname = "consul.homelab"
  domain = "bowmans.site"
  description = "CONSUL"
}
# GRAFANA
resource "opnsense_unbound_host_alias" "GRAFANA" {
  override = opnsense_unbound_host_override.TRAEFIK.id

  enabled = true
  hostname = "grafana.homelab"
  domain = "bowmans.site"
  description = "GRAFANA"
}
# HEIMDALL
resource "opnsense_unbound_host_alias" "HEIMDALL" {
  override = opnsense_unbound_host_override.TRAEFIK.id

  enabled = true
  hostname = "heimdall.homelab"
  domain = "bowmans.site"
  description = "HEIMDALL"
}
# VAULT
resource "opnsense_unbound_host_alias" "VAULT" {
  override = opnsense_unbound_host_override.TRAEFIK.id

  enabled = true
  hostname = "vault.homelab"
  domain = "bowmans.site"
  description = "VAULT"
}