output "host_override_id" {
  description     = "ID of the host override this alias is attached to."
  value           = opnsense_unbound_host_alias.host_alias.override
}

output "enabled" {
  description     = "Host Alias Enabled?"
  value           = opnsense_unbound_host_alias.host_alias.enabled
}

output "description" {
  description     = "Description of the host alias."
  value           = opnsense_unbound_host_alias.host_alias.description
}

output "hostname" {
  description     = "Hostname for the host alias without the domain name."
  value           = opnsense_unbound_host_alias.host_alias.hostname
}

output "domain" {
  description     = "Domain for the host alias."
  value           = opnsense_unbound_host_alias.host_alias.domain
}

output "id" {
  description     = "ID of the host alias."
  value           = opnsense_unbound_host_alias.host_alias.id
}