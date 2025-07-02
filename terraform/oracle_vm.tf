variable "tenancy_ocid" {
  type = string
}
variable "user_ocid" {
  type = string
}
variable "ssh_private_key" {
  type = string
}
variable "ssh_public_key" {
  type = string
}
variable "fingerprint" {
  type = string
}
variable "region" {
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
}

data "oci_identity_availability_domains" "this" {
  compartment_id = var.tenancy_ocid
}

resource "oci_identity_compartment" "this" {
  compartment_id = var.tenancy_ocid
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

data "oci_core_images" "this" {
  for_each = local.instance

  compartment_id = oci_identity_compartment.this.id

  operating_system = each.value.operating_system
  shape            = each.value.shape
  sort_by          = "DISPLAYNAME"
  sort_order       = "DESC"
  state            = "AVAILABLE"
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
    ssh_authorized_keys = var.ssh_public_key
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