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
# HOMER
resource "opnsense_unbound_host_alias" "HOMER" {
  override = opnsense_unbound_host_override.TRAEFIK.id

  enabled = true
  hostname = "homer.homelab"
  domain = "bowmans.site"
  description = "HOMER"
}
# VAULT
resource "opnsense_unbound_host_alias" "VAULT" {
  override = opnsense_unbound_host_override.TRAEFIK.id

  enabled = true
  hostname = "vault.homelab"
  domain = "bowmans.site"
  description = "VAULT"
}
# GITEA
resource "opnsense_unbound_host_alias" "GITEA" {
  override = opnsense_unbound_host_override.TRAEFIK.id

  enabled = true
  hostname = "gitea.homelab"
  domain = "bowmans.site"
  description = "GITEA"
}
# UNIFI
resource "opnsense_unbound_host_alias" "UNIFI" {
  override = opnsense_unbound_host_override.TRAEFIK.id

  enabled = true
  hostname = "unifi.homelab"
  domain = "bowmans.site"
  description = "UNIFI"
}
# WEBSITE
resource "opnsense_unbound_host_alias" "WEBSITE" {
  override = opnsense_unbound_host_override.TRAEFIK.id

  enabled = true
  hostname = "website.homelab"
  domain = "bowmans.site"
  description = "WEBSITE"
}