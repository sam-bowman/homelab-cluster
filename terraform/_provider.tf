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

provider "oci" {
  region        = var.region
  fingerprint   = var.fingerprint
  private_key   = base64decode(var.ssh_private_key_base64)
  tenancy_ocid  = var.tenancy_ocid
  user_ocid     = var.user_ocid
}