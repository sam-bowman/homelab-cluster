variable "host_override_id" {
  description     = "(Required ; Bool) ID of the host override this alias is attached to."
  type            = string
}

variable "enabled" {
  description     = "(Optional ; Bool ; Default = True) Host Alias Enabled?"
  type            = bool
  default         = true
}

variable "description" {
  description     = "(Optional ; Bool ; Default = Same as hostname) Description of the host alias."
  type            = string
  default         = null
}

variable "hostname" {
  description     = "(Required ; Bool) Hostname for the host alias without the domain name."
  type            = string
}

variable "domain" {
  description     = "(Required ; Bool) Domain for the host alias."
  type            = string
}