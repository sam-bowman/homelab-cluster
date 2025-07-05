data "cloudinit_config" "this" {
  for_each = local.instance

  part {
    content = yamlencode(each.value.user_data)

    content_type = "text/cloud-config"
  }
}