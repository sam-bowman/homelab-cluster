locals {
  default_domain = "bowmans.site"
  records = {
    "k3scluster01" = {
      hostname          = "K3SCLUSTER01"
      ip                = "10.10.20.60"
      cf_enabled        = false
    }
    "k3scluster02" = {
      hostname          = "K3SCLUSTER02"
      ip                = "10.10.20.61"
      cf_enabled        = false
    }
    "k3scluster03" = {
      hostname          = "K3SCLUSTER03"
      ip                = "10.10.20.62"
      cf_enabled        = false
    }
    "k3scluster04" = {
      hostname          = "K3SCLUSTER04"
      ip                = "10.10.20.63"
      cf_enabled        = false
    }
    "truenas" = {
      hostname          = "TRUENAS"
      ip                = "10.10.20.50"
      cf_enabled        = false
    }
    "smam_desktop_2" = {
      hostname          = "SMAM-DESKTOP-2"
      ip                = "10.10.10.52"
      cf_enabled        = false
    }
    "pve1" = {
      hostname          = "PVE1"
      ip                = "10.10.20.70"
      cf_enabled        = false
    }
    "ubuntu_vps" = {
      hostname          = "UBUNTU-VPS"
      ip                = oci_core_instance.ubuntu_vps.private_ip
      cf_enabled        = true
      cf_record_type    = "A"
      cf_content        = oci_core_instance.ubuntu_vps.public_ip
      cf_proxy_enabled  = true
    }
    "ubuntu_vps_secondary" = {
      hostname          = "UBUNTU-VPS-SECONDARY"
      ip                = oci_core_instance.ubuntu_vps_secondary.private_ip
      cf_enabled        = true
      cf_record_type    = "A"
      cf_content        = oci_core_instance.ubuntu_vps_secondary.public_ip
      cf_proxy_enabled  = true
    }
    "vm_pterodactyl" = {
      hostname          = "PTERODACTYL"
      ip                = "10.10.20.80"
      cf_enabled        = true
      cf_record_type    = "A"
      cf_content        = oci_core_instance.ubuntu_vps.public_ip
      cf_proxy_enabled  = true
    }
    "vm_zero" = {
      hostname          = "ZERO"
      ip                = "10.10.20.81"
      cf_enabled        = true
      cf_record_type    = "CNAME"
      cf_content        = "home.bowmans.site"
      cf_proxy_enabled  = false
    }
    "vm_haos" = {
      hostname          = "HAOS"
      ip                = "10.10.20.8.82"
      cf_enabled        = false
      cf_record_type    = "CNAME"
      cf_content        = "traefik.bowmans.site"
      cf_proxy_enabled  = true
    }
    "traefik" = {
      hostname          = "TRAEFIK"
      ip                = "10.10.20.101"
      cf_enabled        = true
      cf_record_type    = "A"
      cf_content        = oci_core_instance.ubuntu_vps.public_ip
      cf_proxy_enabled  = true
    }
  }
  aliases         = {
    "factorio" = {
      hostname          = "factorio"
      cf_enabled        = true
      cf_content        = "home.bowmans.site"
      cf_proxy_enabled  = false
      alias_of          = "vm_pterodactyl"
    }
    "minecraft" = {
      hostname          = "minecraft"
      cf_enabled        = true
      cf_content        = "home.bowmans.site"
      cf_proxy_enabled  = false
      alias_of          = "vm_pterodactyl"
    }
    # "wildcard_minecraft" = {
    #   hostname          = "*.minecraft"
    #   cf_enabled        = true
    #   cf_content        = "home.bowmans.site"
    #   cf_proxy_enabled  = false
    #   alias_of          = "vm_pterodactyl"
    # }
    "satisfactory" = {
      hostname          = "satisfactory"
      cf_enabled        = true
      cf_content        = "home.bowmans.site"
      cf_proxy_enabled  = false
      alias_of          = "vm_pterodactyl"
    }
    "api" = {
      hostname          = "api.register.zero"
      cf_enabled        = true
      cf_proxy_enabled  = true
      alias_of          = "vm_zero"
    }
    "argocd" = {
      hostname          = "argocd"
      cf_enabled        = true
      cf_proxy_enabled  = true
      alias_of          = "traefik"
    }
    "bazarr" = {
      hostname          = "bazarr"
      cf_enabled        = true
      cf_proxy_enabled  = true
      alias_of          = "traefik"
    }
    "coder" = {
      hostname          = "coder"
      cf_enabled        = true
      cf_proxy_enabled  = true
      alias_of          = "traefik"
    }
    "consul" = {
      hostname          = "consul"
      cf_enabled        = true
      cf_proxy_enabled  = true
      alias_of          = "traefik"
    }
    "dashboard" = {
      hostname          = "dashboard"
      cf_enabled        = true
      cf_proxy_enabled  = true
      alias_of          = "traefik"
    }
    "gollum" = {
      hostname          = "gollum"
      cf_enabled        = true
      cf_proxy_enabled  = true
      alias_of          = "traefik"
    }
    "hass" = {
      hostname          = "hass"
      cf_enabled        = true
      cf_proxy_enabled  = true
      alias_of          = "traefik"
    }
    "homer" = {
      hostname          = "homer"
      cf_enabled        = true
      cf_proxy_enabled  = true
      alias_of          = "traefik"
    }
    "longhorn" = {
      hostname          = "longhorn"
      cf_enabled        = true
      cf_proxy_enabled  = true
      alias_of          = "traefik"
    }
    "maintainerr" = {
      hostname          = "maintainerr"
      cf_enabled        = true
      cf_proxy_enabled  = true
      alias_of          = "traefik"
    }
    "netbox" = {
      hostname          = "netbox"
      cf_enabled        = true
      cf_proxy_enabled  = true
      alias_of          = "traefik"
    }
    "overseerr" = {
      hostname          = "overseerr"
      cf_enabled        = true
      cf_proxy_enabled  = true
      alias_of          = "traefik"
    }
    "plex" = {
      hostname          = "plex"
      cf_enabled        = true
      cf_proxy_enabled  = true
      alias_of          = "traefik"
    }
    "radarr" = {
      hostname          = "radarr"
      cf_enabled        = true
      cf_proxy_enabled  = true
      alias_of          = "traefik"
    }
    "readarr" = {
      hostname          = "readarr"
      cf_enabled        = true
      cf_proxy_enabled  = true
      alias_of          = "traefik"
    }
    "register_zero" = {
      hostname          = "register-zero"
      cf_enabled        = true
      cf_proxy_enabled  = true
      alias_of          = "traefik"
    }
    "requestrr" = {
      hostname          = "requestrr"
      cf_enabled        = true
      cf_proxy_enabled  = true
      alias_of          = "traefik"
    }
    "sabnzbd" = {
      hostname          = "sabnzbd"
      cf_enabled        = true
      cf_proxy_enabled  = true
      alias_of          = "traefik"
    }
    "sonarr" = {
      hostname          = "sonarr"
      cf_enabled        = true
      cf_proxy_enabled  = true
      alias_of          = "traefik"
    }
    "tautulli" = {
      hostname          = "tautulli"
      cf_enabled        = true
      cf_proxy_enabled  = true
      alias_of          = "traefik"
    }
    "tdarr" = {
      hostname          = "tdarr"
      cf_enabled        = true
      cf_proxy_enabled  = true
      alias_of          = "traefik"
    }
    "titlecardmaker" = {
      hostname          = "titlecardmaker"
      cf_enabled        = true
      cf_proxy_enabled  = true
      alias_of          = "traefik"
    }
    "unifi" = {
      hostname          = "unifi"
      cf_enabled        = true
      cf_proxy_enabled  = true
      alias_of          = "traefik"
    }
    "vault" = {
      hostname          = "vault"
      cf_enabled        = true
      cf_proxy_enabled  = true
      alias_of          = "traefik"
    }
  }
}