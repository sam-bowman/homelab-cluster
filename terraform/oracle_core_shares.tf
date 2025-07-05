data "oci_core_shapes" "this" {
  for_each = toset(data.oci_identity_availability_domains.this.availability_domains[*].name)

  compartment_id = oci_identity_compartment.this.id

  availability_domain = each.key
}