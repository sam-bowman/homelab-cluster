variable "oracle_tenancy_ocid" {
  type = string
}
variable "oracle_user_ocid" {
  type = string
}
variable "oracle_ssh_private_key_base64" {
  type = string
}
variable "oracle_ssh_public_key_base64" {
  type = string
}
variable "oracle_fingerprint" {
  type = string
}
variable "oracle_region" {
  type = string
}

locals {
  instance = {
    ubuntu = {
      shape : "VM.Standard.E2.1.Micro",
      operating_system = "Canonical Ubuntu",
      user_data : {
        runcmd : ["apt-get remove --quiet --assume-yes --purge apparmor"],
      },
    },
  }
  protocol_number = {
    icmp   = 1
    icmpv6 = 58
    tcp    = 6
    udp    = 17
  }
}

data "oci_identity_availability_domains" "this" {
  compartment_id = var.oracle_tenancy_ocid
}

resource "oci_identity_compartment" "this" {
  compartment_id = var.oracle_tenancy_ocid
  description    = "my compartment"
  name           = replace("my-compartment", " ", "-")

  enable_delete = true
}

data "oci_core_shapes" "this" {
  for_each = toset(data.oci_identity_availability_domains.this.availability_domains[*].name)

  compartment_id = oci_identity_compartment.this.id

  availability_domain = each.key
}

data "cloudinit_config" "this" {
  for_each = local.instance

  part {
    content = yamlencode(each.value.user_data)

    content_type = "text/cloud-config"
  }
}

resource "oci_core_vcn" "this" {
  compartment_id = oci_identity_compartment.this.id

  cidr_blocks  = ["10.20.10.0/24"]
  display_name = "my-vcn"
  dns_label    = "vcn"
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

data "oci_core_images" "this" {
  for_each = local.instance

  compartment_id = oci_identity_compartment.this.id

  operating_system = each.value.operating_system
  shape            = each.value.shape
  sort_by          = "DISPLAYNAME"
  sort_order       = "DESC"
  state            = "AVAILABLE"
}

resource "oci_core_subnet" "this" {
  cidr_block     = oci_core_vcn.this.cidr_blocks.0
  compartment_id = oci_identity_compartment.this.id
  vcn_id         = oci_core_vcn.this.id

  display_name = oci_core_vcn.this.display_name
  dns_label    = "subnet"
}

resource "oci_core_instance" "ubuntu_vps" {
  availability_domain = one(
    [
      for m in data.oci_core_shapes.this :
      m.availability_domain
      if contains(m.shapes[*].name, local.instance.ubuntu.shape)
    ]
  )
  compartment_id = oci_identity_compartment.this.id
  shape          = local.instance.ubuntu.shape

  display_name         = "Ubuntu VPS"
  preserve_boot_volume = false

  metadata = {
    ssh_authorized_keys = base64decode(var.oracle_ssh_public_key_base64)
    user_data           = data.cloudinit_config.this["ubuntu"].rendered
  }

  agent_config {
    are_all_plugins_disabled = true
    is_management_disabled   = true
    is_monitoring_disabled   = true
  }

  create_vnic_details {
    display_name   = "Ubuntu VPS"
    hostname_label = "ubuntu-vps"
    nsg_ids        = [oci_core_network_security_group.this.id]
    subnet_id      = oci_core_subnet.this.id
  }

  source_details {
    source_id               = data.oci_core_images.this["ubuntu"].images.0.id
    source_type             = "image"
    boot_volume_size_in_gbs = 50
  }

  lifecycle {
    ignore_changes = [source_details.0.source_id]
  }
}

data "oci_core_private_ips" "this" {
  ip_address = oci_core_instance.ubuntu_vps.private_ip
  subnet_id  = oci_core_subnet.this.id
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
  }

  ingress_security_rules {
    protocol    = local.protocol_number.tcp
    source      = "0.0.0.0/0"
    description = "HTTP traffic from any origin"
    tcp_options {
      min = "80"
      max = "80"
    }
  }

  ingress_security_rules {
    protocol    = local.protocol_number.tcp
    source      = "0.0.0.0/0"
    description = "HTTPS traffic from any origin"
    tcp_options {
      min = "443"
      max = "443"
    }
  }

  ingress_security_rules {
    protocol    = local.protocol_number.udp
    source      = "0.0.0.0/0"
    description = "Wireguard traffic from any origin"
    udp_options {
      min = "51820"
      max = "51820"
    }
  }

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"

    description = "All traffic to any destination"
  }
}