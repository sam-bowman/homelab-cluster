# diagram.py
from diagrams import Diagram, Cluster, Edge
from diagrams.onprem import network as onprem_network
from diagrams.generic import network as generic_network
from diagrams.generic import os as generic_os
from diagrams.custom import Custom
from diagrams.k8s import network as k8s_network

if __name__ == "__main__":
    with Diagram("SMAM-HOMELAB", show=False):
        internet = onprem_network.Internet("Internet")
        firewall = onprem_network.Opnsense("firewall")
        internet \
            >> Edge(color="darkgreen") \
            << firewall
        with Cluster("SMAM-SW-2"):
            smam_sw_2 = generic_network.Switch("SMAM-SW-2")
            firewall \
                >> Edge(color="darkgreen") \
                << smam_sw_2
            smam_ap_1 = generic_network.Router("SMAM-AP-1")
            smam_sw_2 \
                >> Edge(color="darkgreen") \
                << smam_ap_1
            smam_desktop_1 = generic_os.Windows("SMAM-DESKTOP-1")
            smam_sw_2 \
                >> Edge(color="darkgreen") \
                << smam_desktop_1
            with Cluster("SMAM-SW-1"):
                smam_sw_1 = generic_network.Switch("SMAM-SW-1")
                smam_sw_2 \
                    >> Edge(color="darkgreen", ) \
                    << smam_sw_1
                with Cluster("TRUENAS"):
                    truenas = generic_os.Debian("TRUENAS")
                    smam_sw_1 \
                        >> Edge(color="darkgreen") \
                        << truenas
                    truenas_apps =  [
                        Custom("Bazarr", "../argocd/utility/homer/config/images/bazarr-logo.png"),
                        Custom("Overseerr", "../argocd/utility/homer/config/images/overseerr-logo.svg"),
                        Custom("Plex", "../argocd/utility/homer/config/images/plex-logo.svg"),
                        Custom("Radarr", "../argocd/utility/homer/config/images/radarr-logo.png"),
                        Custom("Requestrr", "../argocd/utility/homer/config/images/requestrr-logo.png"),
                        Custom("SabNZBD", "../argocd/utility/homer/config/images/sabnzbd-logo.png"),
                        Custom("Sonarr", "../argocd/utility/homer/config/images/sonarr-logo.png"),
                        Custom("Tautulli", "../argocd/utility/homer/config/images/tautulli-logo.png"),
                        Custom("TDarr", "../argocd/utility/homer/config/images/tdarr-logo.ico"),
                        Custom("Bazarr", "../argocd/utility/homer/config/images/tcm-logo.png")
                    ]
                    truenas \
                        >> Edge(color="darkgreen") \
                        << truenas_apps
                with Cluster("K3SCLUSTER"):
                    k3scluster = [
                        generic_os.Raspbian("K3SCLUSTER01"),
                        generic_os.Raspbian("K3SCLUSTER02"),
                        generic_os.Raspbian("K3SCLUSTER03"),
                        generic_os.Raspbian("K3SCLUSTER04")
                    ]
                    smam_sw_1 \
                        >> Edge(color="darkgreen") \
                        << k3scluster
                    traefik = k8s_network.Ing("Traefik Ingress")
                    k3scluster \
                        >> Edge(color="darkgreen") \
                        << traefik