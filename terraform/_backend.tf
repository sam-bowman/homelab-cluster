terraform {
  backend "consul" {
    address = "consul.bowmans.site"
    scheme  = "https"
    path    = "terraform/fw-config-state.tfstate"
  }
}