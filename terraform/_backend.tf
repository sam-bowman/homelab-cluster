terraform {
  backend "consul" {
    address = "consul.homelab.bowmans.site"
    scheme  = "https"
    path    = "terraform/fw-config-state.tfstate"
  }
}