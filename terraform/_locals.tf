locals {
  default_domain = "bowmans.site"
  overrides = {
    k3scluster01 = {
      hostname        = "K3SCLUSTER01"
      ip              = "10.10.20.60"
    }
    k3scluster02 = {
      hostname        = "K3SCLUSTER02"
      ip              = "10.10.20.61"
    }
    k3scluster03 = {
      hostname        = "K3SCLUSTER03"
      ip              = "10.10.20.62"
    }
    k3scluster04 = {
      hostname        = "K3SCLUSTER04"
      ip              = "10.10.20.63"
    }
    traefik = {
      hostname        = "traefik.homelab"
      ip              = "10.10.20.101"
      aliases         = {
        argocd = {
          hostname = "argocd.homelab"
        }
        consul = {
          hostname = "consul.homelab"
        }
        homer = {
          hostname = "homer.homelab"
        }
        dashboard = {
          hostname = "dashboard.homelab"
        }
        vault = {
          hostname = "vault.homelab"
        }
        unifi = {
          hostname = "unifi.homelab"
        }
        traefik = {
          hostname = "traefik.homelab"
        }
        netbox = {
          hostname = "netbox.homelab"
        }
        longhorn = {
          hostname = "longhorn.homelab"
        }
        requestrr = {
          hostname = "requestrr.homelab"
        }
        overseerr = {
          hostname = "overseerr.homelab"
        }
        maintainerr = {
          hostname = "maintainerr.homelab"
        }
        tautulli = {
          hostname = "tautulli.homelab"
        }
        coder = {
          hostname = "coder.homelab"
        }
        gollum = {
          hostname = "gollum.homelab"
        }
        bazarr = {
          hostname = "bazarr"
        }
        plex = {
          hostname = "plex"
        }
        radarr = {
          hostname = "radarr"
        }
        sabnzbd = {
          hostname = "sabnzbd"
        }
        sonarr = {
          hostname = "sonarr"
        }
        readarr = {
          hostname = "readarr"
        }
        titlecardmaker = {
          hostname = "titlecardmaker"
        }
        tdarr = {
          hostname = "tdarr"
        }
      }
    }
  }
}