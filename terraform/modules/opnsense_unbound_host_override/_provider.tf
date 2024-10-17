terraform {
  required_providers {
    opnsense = {
      source = "browningluke/opnsense"
      version = "0.11.0"
    }
  }
}

provider "opnsense" {
  # Configuration options, configured using environment variables passed in via the pipeline
}