resource "opnsense_firewall_nat" "WEBSITE" {
  enabled = false

  interface = "V3000_WAN"
  protocol  = "TCP"

  destination = {
    net  = "W3000_WAN address"
    port = "443"
  }

  target = {
    ip = opnsense_unbound_host_override.TRAEFIK.server
    port = "443"
  }

  log         = true
  description = "WEBSITE NAT"
}