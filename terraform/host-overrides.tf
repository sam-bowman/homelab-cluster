# CLUSTER NODES
resource "opnsense_unbound_host_override" "K3SCLUSTER01" {
  enabled = true
  description = "K3SCLUSTER01"

  hostname = "K3SCLUSTER01"
  domain = "bowmans.site"
  server = "10.10.20.60"
}
resource "opnsense_unbound_host_override" "K3SCLUSTER02" {
  enabled = true
  description = "K3SCLUSTER02"

  hostname = "K3SCLUSTER02"
  domain = "bowmans.site"
  server = "10.10.20.61"
}
resource "opnsense_unbound_host_override" "K3SCLUSTER03" {
  enabled = true
  description = "K3SCLUSTER03"

  hostname = "K3SCLUSTER03"
  domain = "bowmans.site"
  server = "10.10.20.62"
}
resource "opnsense_unbound_host_override" "K3SCLUSTER04" {
  enabled = true
  description = "K3SCLUSTER04"

  hostname = "K3SCLUSTER04"
  domain = "bowmans.site"
  server = "10.10.20.63"
}

# TRAEFIK INGRESS
resource "opnsense_unbound_host_override" "TRAEFIK" {
  enabled = true
  description = "TRAEFIK"

  hostname = "traefik.homelab"
  domain = "bowmans.site"
  server = "10.10.20.101"
}