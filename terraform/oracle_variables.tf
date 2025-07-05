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