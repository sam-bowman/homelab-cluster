output "enabled" {
  description     = "Host Override Enabled?"
  value           = opnsense_unbound_host_override.host_override.enabled
}

output "description" {
  description     = "Description of the host override."
  value           = opnsense_unbound_host_override.host_override.description
}

output "hostname" {
  description     = "Hostname for the host override without the domain."
  value           = opnsense_unbound_host_override.host_override.hostname
}

output "domain" {
  description     = "Domain for the host override."
  value           = opnsense_unbound_host_override.host_override.domain
}

output "ip" {
  description     = "Target IP for the host override."
  value           = opnsense_unbound_host_override.host_override.server
}

output "id" {
  description     = "ID for the host override."
  value           = opnsense_unbound_host_override.host_override.id
}