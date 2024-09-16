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
# KUBERNETES DASHBOARD
resource "opnsense_unbound_host_alias" "KUBERNETES_DASHBOARD" {
  override = opnsense_unbound_host_override.TRAEFIK.id

  enabled = true
  hostname = "dashboard.homelab"
  domain = "bowmans.site"
  description = "KUBERNETES DASHBOARD"
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
# TRAEFIK-DASHBOARD
resource "opnsense_unbound_host_alias" "TRAEFIK" {
  override = opnsense_unbound_host_override.TRAEFIK.id

  enabled = true
  hostname = "traefik.homelab"
  domain = "bowmans.site"
  description = "TRAEFIK"
}
# NETBOX
resource "opnsense_unbound_host_alias" "NETBOX" {
  override = opnsense_unbound_host_override.TRAEFIK.id

  enabled = true
  hostname = "netbox.homelab"
  domain = "bowmans.site"
  description = "NETBOX"
}




### EXTERNAL SERVICES
# BAZARR
resource "opnsense_unbound_host_alias" "BAZARR" {
  override = opnsense_unbound_host_override.TRAEFIK.id

  enabled = true
  hostname = "bazarr"
  domain = "bowmans.site"
  description = "BAZARR"
}
# PLEX
resource "opnsense_unbound_host_alias" "PLEX" {
  override = opnsense_unbound_host_override.TRAEFIK.id

  enabled = true
  hostname = "plex"
  domain = "bowmans.site"
  description = "PLEX"
}
# RADARR
resource "opnsense_unbound_host_alias" "RADARR" {
  override = opnsense_unbound_host_override.TRAEFIK.id

  enabled = true
  hostname = "radarr"
  domain = "bowmans.site"
  description = "RADARR"
}
# REQUESTRR
resource "opnsense_unbound_host_alias" "REQUESTRR" {
  override = opnsense_unbound_host_override.TRAEFIK.id

  enabled = true
  hostname = "requestrr"
  domain = "bowmans.site"
  description = "REQUESTRR"
}
# SABNZBD
resource "opnsense_unbound_host_alias" "SABNZBD" {
  override = opnsense_unbound_host_override.TRAEFIK.id

  enabled = true
  hostname = "sabnzbd"
  domain = "bowmans.site"
  description = "SABNZBD"
}
# SONARR
resource "opnsense_unbound_host_alias" "SONARR" {
  override = opnsense_unbound_host_override.TRAEFIK.id

  enabled = true
  hostname = "sonarr"
  domain = "bowmans.site"
  description = "SONARR"
}
# OVERSEERR
resource "opnsense_unbound_host_alias" "OVERSEERR" {
  override = opnsense_unbound_host_override.TRAEFIK.id

  enabled = true
  hostname = "overseerr"
  domain = "bowmans.site"
  description = "OVERSEERR"
}
# TITLECARDMAKERGUI
resource "opnsense_unbound_host_alias" "TITLECARDMAKERGUI" {
  override = opnsense_unbound_host_override.TRAEFIK.id

  enabled = true
  hostname = "titlecardmaker"
  domain = "bowmans.site"
  description = "TITLECARDMAKERGUI"
}
# SYNCTHING
resource "opnsense_unbound_host_alias" "SYNCTHING" {
  override = opnsense_unbound_host_override.TRAEFIK.id

  enabled = true
  hostname = "syncthing"
  domain = "bowmans.site"
  description = "SYNCTHING"
}
# TAUTULLI
resource "opnsense_unbound_host_alias" "TAUTULLI" {
  override = opnsense_unbound_host_override.TRAEFIK.id

  enabled = true
  hostname = "tautulli"
  domain = "bowmans.site"
  description = "TAUTULLI"
}
# TDARR
resource "opnsense_unbound_host_alias" "TDARR" {
  override = opnsense_unbound_host_override.TRAEFIK.id

  enabled = true
  hostname = "tdarr"
  domain = "bowmans.site"
  description = "TDARR"
}
# AIRDCPP
resource "opnsense_unbound_host_alias" "AIRDCPP" {
  override = opnsense_unbound_host_override.TRAEFIK.id

  enabled = true
  hostname = "airdcpp"
  domain = "bowmans.site"
  description = "AIRDCPP"
}