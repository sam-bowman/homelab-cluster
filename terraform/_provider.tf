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
  region        = var.oracle_region
  fingerprint   = var.oracle_fingerprint
  private_key   = base64decode(var.oracle_ssh_private_key_base64)
  tenancy_ocid  = var.oracle_tenancy_ocid
  user_ocid     = var.oracle_user_ocid
}