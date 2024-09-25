# ARGOCD-K8S
resource "opnsense_unbound_host_alias" "ARGOCD-K8S" {
  override = opnsense_unbound_host_override.TRAEFIK.id

  enabled = true
  hostname = "argocd.homelab"
  domain = "bowmans.site"
  description = "ARGOCD-K8S"
}
# CONSUL-K8S
resource "opnsense_unbound_host_alias" "CONSUL-K8S" {
  override = opnsense_unbound_host_override.TRAEFIK.id

  enabled = true
  hostname = "consul.homelab"
  domain = "bowmans.site"
  description = "CONSUL-K8S"
}
# HOMER-K8S
resource "opnsense_unbound_host_alias" "HOMER-K8S" {
  override = opnsense_unbound_host_override.TRAEFIK.id

  enabled = true
  hostname = "homer.homelab"
  domain = "bowmans.site"
  description = "HOMER-K8S"
}
# KUBERNETES DASHBOARD-K8S
resource "opnsense_unbound_host_alias" "KUBERNETES_DASHBOARD-K8S" {
  override = opnsense_unbound_host_override.TRAEFIK.id

  enabled = true
  hostname = "dashboard.homelab"
  domain = "bowmans.site"
  description = "KUBERNETES DASHBOARD-K8S"
}
# VAULT-K8S
resource "opnsense_unbound_host_alias" "VAULT-K8S" {
  override = opnsense_unbound_host_override.TRAEFIK.id

  enabled = true
  hostname = "vault.homelab"
  domain = "bowmans.site"
  description = "VAULT-K8S"
}
# UNIFI-K8S
resource "opnsense_unbound_host_alias" "UNIFI-K8S" {
  override = opnsense_unbound_host_override.TRAEFIK.id

  enabled = true
  hostname = "unifi.homelab"
  domain = "bowmans.site"
  description = "UNIFI-K8S"
}
# TRAEFIK-DASHBOARD-K8S
resource "opnsense_unbound_host_alias" "TRAEFIK-K8S" {
  override = opnsense_unbound_host_override.TRAEFIK.id

  enabled = true
  hostname = "traefik.homelab"
  domain = "bowmans.site"
  description = "TRAEFIK-K8S"
}
# NETBOX-K8S
resource "opnsense_unbound_host_alias" "NETBOX-K8S" {
  override = opnsense_unbound_host_override.TRAEFIK.id

  enabled = true
  hostname = "netbox.homelab"
  domain = "bowmans.site"
  description = "NETBOX-K8S"
}
# LONGHORN-K8S
resource "opnsense_unbound_host_alias" "LONGHORN-K8S" {
  override = opnsense_unbound_host_override.TRAEFIK.id

  enabled = true
  hostname = "longhorn.homelab"
  domain = "bowmans.site"
  description = "LONGHORN-K8S"
}
# REQUESTRR-K8S
resource "opnsense_unbound_host_alias" "REQUESTRR-K8S" {
  override = opnsense_unbound_host_override.TRAEFIK.id

  enabled = true
  hostname = "requestrr.homelab"
  domain = "bowmans.site"
  description = "REQUESTRR-K8S"
}
# OVERSEERR-K8S
resource "opnsense_unbound_host_alias" "OVERSEERR-K8S" {
  override = opnsense_unbound_host_override.TRAEFIK.id

  enabled = true
  hostname = "overseerr.homelab"
  domain = "bowmans.site"
  description = "OVERSEERR-K8S"
}
# MAINTAINERR-K8S
resource "opnsense_unbound_host_alias" "MAINTAINERR-K8S" {
  override = opnsense_unbound_host_override.TRAEFIK.id

  enabled = true
  hostname = "maintainerr.homelab"
  domain = "bowmans.site"
  description = "MAINTAINERR-K8S"
}
# TAUTULLI-K8S
resource "opnsense_unbound_host_alias" "TAUTULLI-K8S" {
  override = opnsense_unbound_host_override.TRAEFIK.id

  enabled = true
  hostname = "tautulli.homelab"
  domain = "bowmans.site"
  description = "TAUTULLI-K8S"
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
# TITLECARDMAKERGUI
resource "opnsense_unbound_host_alias" "TITLECARDMAKERGUI" {
  override = opnsense_unbound_host_override.TRAEFIK.id

  enabled = true
  hostname = "titlecardmaker"
  domain = "bowmans.site"
  description = "TITLECARDMAKERGUI"
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