terraform {
  required_providers {
    opnsense = {
      source = "browningluke/opnsense"
      version = "0.10.1"
    }
  }
}

provider "opnsense" {
  # Configured via envs
}