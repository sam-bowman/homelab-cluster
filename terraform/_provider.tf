terraform {
  required_providers {
    opnsense = {
      source = "browningluke/opnsense"
      version = "0.11.0"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "5.6.0"
    }
    oci = {
      source = "oracle/oci"
      version = "7.7.0"
    }
  }
}