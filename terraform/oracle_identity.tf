data "oci_identity_availability_domains" "this" {
  compartment_id = var.oracle_tenancy_ocid
}

resource "oci_identity_compartment" "this" {
  compartment_id = var.oracle_tenancy_ocid
  description    = "my compartment"
  name           = replace("my-compartment", " ", "-")

  enable_delete = true
}
