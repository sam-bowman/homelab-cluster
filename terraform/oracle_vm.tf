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

resource "oci_core_instance" "ubuntu_vps_secondary" {
  availability_domain = one(
    [
      for m in data.oci_core_shapes.this :
      m.availability_domain
      if contains(m.shapes[*].name, local.instance.ubuntu.shape)
    ]
  )
  compartment_id = oci_identity_compartment.this.id
  shape          = local.instance.ubuntu.shape

  display_name         = "Ubuntu VPS Secondary"
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
    display_name   = "Ubuntu VPS Secondary"
    hostname_label = "ubuntu-vps-secondary"
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