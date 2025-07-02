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
    "vm_pterodactyl" = {
      hostname          = "PTERODACTYL"
      ip                = "10.10.20.80"
      cf_enabled        = true
      cd_record_type    = "A"
      cf_content        = oci_core_instance.ubuntu_vps.public_ip
      cf_proxy_enabled  = true
    }
    "vm_zero" = {
      hostname          = "ZERO"
      ip                = "10.10.20.81"
      cf_enabled        = true
      cd_record_type    = "CNAME"
      cf_content        = "home.bowmans.site"
      cf_proxy_enabled  = false
    }
    "traefik_homelab" = {
      hostname          = "TRAEFIK.HOMELAB"
      ip                = "10.10.20.101"
      cf_enabled        = true
      cd_record_type    = "A"
      cf_content        = oci_core_instance.ubuntu_vps.public_ip
      cf_proxy_enabled  = true
    }
  }
  aliases         = {
    "factorio" = {
      hostname          = "factorio"
      cf_enabled        = true
      cd_record_type    = "CNAME"
      cf_content        = "home.bowmans.site"
      cf_proxy_enabled  = false
      alias_of          = "vm_pterodactyl"
    }
    "minecraft" = {
      hostname          = "minecraft"
      cf_enabled        = true
      cd_record_type    = "CNAME"
      cf_content        = "home.bowmans.site"
      cf_proxy_enabled  = false
      alias_of          = "vm_pterodactyl"
    }
    # "wildcard_minecraft" = {
    #   hostname          = "*.minecraft"
    #   cf_enabled        = true
    #   cf_content        = oci_core_instance.ubuntu_vps.public_ip
    #   cf_proxy_enabled  = false
    #   alias_of          = "vm_pterodactyl"
    # }
    "satisfactory" = {
      hostname          = "satisfactory"
      cf_enabled        = true
      cd_record_type    = "CNAME"
      cf_content        = "home.bowmans.site"
      cf_proxy_enabled  = false
      alias_of          = "vm_pterodactyl"
    }
    "api" = {
      hostname          = "api.register.zero"
      cf_enabled        = true
      cd_record_type    = "A"
      cf_content        = oci_core_instance.ubuntu_vps.public_ip
      cf_proxy_enabled  = true
      alias_of          = "vm_zero"
    }
    "argocd_homelab" = {
      hostname          = "argocd.homelab"
      cf_enabled        = true
      cd_record_type    = "A"
      cf_content        = oci_core_instance.ubuntu_vps.public_ip
      cf_proxy_enabled  = true
      alias_of          = "traefik_homelab"
    }
    "bazarr" = {
      hostname          = "bazarr"
      cf_enabled        = true
      cd_record_type    = "A"
      cf_content        = oci_core_instance.ubuntu_vps.public_ip
      cf_proxy_enabled  = true
      alias_of          = "traefik_homelab"
    }
    "coder_homelab" = {
      hostname          = "coder.homelab"
      cf_enabled        = true
      cd_record_type    = "A"
      cf_content        = oci_core_instance.ubuntu_vps.public_ip
      cf_proxy_enabled  = true
      alias_of          = "traefik_homelab"
    }
    "consul_homelab" = {
      hostname          = "consul.homelab"
      cf_enabled        = true
      cd_record_type    = "A"
      cf_content        = oci_core_instance.ubuntu_vps.public_ip
      cf_proxy_enabled  = true
      alias_of          = "traefik_homelab"
    }
    "dashboard_homelab" = {
      hostname          = "dashboard.homelab"
      cf_enabled        = true
      cd_record_type    = "A"
      cf_content        = oci_core_instance.ubuntu_vps.public_ip
      cf_proxy_enabled  = true
      alias_of          = "traefik_homelab"
    }
    "gollum_homelab" = {
      hostname          = "gollum.homelab"
      cf_enabled        = true
      cd_record_type    = "A"
      cf_content        = oci_core_instance.ubuntu_vps.public_ip
      cf_proxy_enabled  = true
      alias_of          = "traefik_homelab"
    }
    "homer_homelab" = {
      hostname          = "homer.homelab"
      cf_enabled        = true
      cd_record_type    = "A"
      cf_content        = oci_core_instance.ubuntu_vps.public_ip
      cf_proxy_enabled  = true
      alias_of          = "traefik_homelab"
    }
    "longhorn_homelab" = {
      hostname          = "longhorn.homelab"
      cf_enabled        = true
      cd_record_type    = "A"
      cf_content        = oci_core_instance.ubuntu_vps.public_ip
      cf_proxy_enabled  = true
      alias_of          = "traefik_homelab"
    }
    "maintainerr_homelab" = {
      hostname          = "maintainerr.homelab"
      cf_enabled        = true
      cd_record_type    = "A"
      cf_content        = oci_core_instance.ubuntu_vps.public_ip
      cf_proxy_enabled  = true
      alias_of          = "traefik_homelab"
    }
    "netbox_homelab" = {
      hostname          = "netbox.homelab"
      cf_enabled        = true
      cd_record_type    = "A"
      cf_content        = oci_core_instance.ubuntu_vps.public_ip
      cf_proxy_enabled  = true
      alias_of          = "traefik_homelab"
    }
    "overseerr_homelab" = {
      hostname          = "overseerr.homelab"
      cf_enabled        = true
      cd_record_type    = "A"
      cf_content        = oci_core_instance.ubuntu_vps.public_ip
      cf_proxy_enabled  = true
      alias_of          = "traefik_homelab"
    }
    "plex" = {
      hostname          = "plex"
      cf_enabled        = true
      cd_record_type    = "A"
      cf_content        = oci_core_instance.ubuntu_vps.public_ip
      cf_proxy_enabled  = true
      alias_of          = "traefik_homelab"
    }
    "radarr" = {
      hostname          = "radarr"
      cf_enabled        = true
      cd_record_type    = "A"
      cf_content        = oci_core_instance.ubuntu_vps.public_ip
      cf_proxy_enabled  = true
      alias_of          = "traefik_homelab"
    }
    "readarr" = {
      hostname          = "readarr"
      cf_enabled        = true
      cd_record_type    = "A"
      cf_content        = oci_core_instance.ubuntu_vps.public_ip
      cf_proxy_enabled  = true
      alias_of          = "traefik_homelab"
    }
    "register_zero" = {
      hostname          = "register-zero"
      cf_enabled        = true
      cd_record_type    = "A"
      cf_content        = oci_core_instance.ubuntu_vps.public_ip
      cf_proxy_enabled  = true
      alias_of          = "traefik_homelab"
    }
    "requestrr_homelab" = {
      hostname          = "requestrr.homelab"
      cf_enabled        = true
      cd_record_type    = "A"
      cf_content        = oci_core_instance.ubuntu_vps.public_ip
      cf_proxy_enabled  = true
      alias_of          = "traefik_homelab"
    }
    "sabnzbd" = {
      hostname          = "sabnzbd"
      cf_enabled        = true
      cd_record_type    = "A"
      cf_content        = oci_core_instance.ubuntu_vps.public_ip
      cf_proxy_enabled  = true
      alias_of          = "traefik_homelab"
    }
    "sonarr" = {
      hostname          = "sonarr"
      cf_enabled        = true
      cd_record_type    = "A"
      cf_content        = oci_core_instance.ubuntu_vps.public_ip
      cf_proxy_enabled  = true
      alias_of          = "traefik_homelab"
    }
    "tautulli_homelab" = {
      hostname          = "tautulli.homelab"
      cf_enabled        = true
      cd_record_type    = "A"
      cf_content        = oci_core_instance.ubuntu_vps.public_ip
      cf_proxy_enabled  = true
      alias_of          = "traefik_homelab"
    }
    "tdarr" = {
      hostname          = "tdarr"
      cf_enabled        = true
      cd_record_type    = "A"
      cf_content        = oci_core_instance.ubuntu_vps.public_ip
      cf_proxy_enabled  = true
      alias_of          = "traefik_homelab"
    }
    "titlecardmaker" = {
      hostname          = "titlecardmaker"
      cf_enabled        = true
      cd_record_type    = "A"
      cf_content        = oci_core_instance.ubuntu_vps.public_ip
      cf_proxy_enabled  = true
      alias_of          = "traefik_homelab"
    }
    "unifi_homelab" = {
      hostname          = "unifi.homelab"
      cf_enabled        = true
      cd_record_type    = "A"
      cf_content        = oci_core_instance.ubuntu_vps.public_ip
      cf_proxy_enabled  = true
      alias_of          = "traefik_homelab"
    }
    "vault_homelab" = {
      hostname          = "vault.homelab"
      cf_enabled        = true
      cd_record_type    = "A"
      cf_content        = oci_core_instance.ubuntu_vps.public_ip
      cf_proxy_enabled  = true
      alias_of          = "traefik_homelab"
    }
  }
}