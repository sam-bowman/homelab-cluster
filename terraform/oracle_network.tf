resource "oci_core_vcn" "this" {
  compartment_id = oci_identity_compartment.this.id

  cidr_blocks  = ["10.20.10.0/24"]
  display_name = "my-vcn"
  dns_label    = "vcn"
}

resource "oci_core_subnet" "this" {
  cidr_block     = oci_core_vcn.this.cidr_blocks.0
  compartment_id = oci_identity_compartment.this.id
  vcn_id         = oci_core_vcn.this.id

  display_name = oci_core_vcn.this.display_name
  dns_label    = "subnet"
}

resource "oci_core_network_security_group" "this" {
  compartment_id = oci_identity_compartment.this.id
  vcn_id         = oci_core_vcn.this.id

  display_name = oci_core_vcn.this.display_name
}

resource "oci_core_network_security_group_security_rule" "this" {
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.this.id
  protocol                  = local.protocol_number.icmp
  source                    = "0.0.0.0/0"
}

resource "oci_core_internet_gateway" "this" {
  compartment_id = oci_identity_compartment.this.id
  vcn_id         = oci_core_vcn.this.id

  display_name = oci_core_vcn.this.display_name
}

resource "oci_core_default_route_table" "this" {
  manage_default_resource_id = oci_core_vcn.this.default_route_table_id

  display_name = oci_core_vcn.this.display_name

  route_rules {
    network_entity_id = oci_core_internet_gateway.this.id

    description = "Default route"
    destination = "0.0.0.0/0"
  }
}

resource "oci_core_default_security_list" "this" {
  manage_default_resource_id = oci_core_vcn.this.default_security_list_id

  ingress_security_rules {
    protocol    = local.protocol_number.tcp
    source      = "0.0.0.0/0"
    description = "SSH traffic from any origin"
    tcp_options {
      min = "22"
      max = "22"
    }
    stateless = false
  }

  ingress_security_rules {
    protocol    = local.protocol_number.tcp
    source      = "0.0.0.0/0"
    description = "HTTP traffic from any origin"
    tcp_options {
      min = "80"
      max = "80"
    }
    stateless = false
  }

  ingress_security_rules {
    protocol    = local.protocol_number.tcp
    source      = "0.0.0.0/0"
    description = "HTTPS traffic from any origin"
    tcp_options {
      min = "443"
      max = "443"
    }
    stateless = false
  }

  ingress_security_rules {
    protocol    = local.protocol_number.udp
    source      = "0.0.0.0/0"
    description = "Wireguard traffic from any origin"
    udp_options {
      min = "51820"
      max = "51820"
    }
    stateless = false
  }

  ingress_security_rules {
    protocol    = local.protocol_number.icmp
    source      = "0.0.0.0/0"
    description = "ICMP"
  }

  ingress_security_rules {
    protocol    = "all"
    source      = "10.10.0.0/16"
    description = "Private traffic for all protocols"
    stateless = false
  }

  ingress_security_rules {
    protocol    = "all"
    source      = "10.20.0.0/16"
    description = "Private traffic for all protocols"
    stateless = false
  }

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"

    description = "All traffic to any destination"
  }
}