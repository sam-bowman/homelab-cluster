variable "enabled" {
  description     = "(Optional ; Bool ; Default = True) Host Override Enabled?"
  type            = bool
  default         = true
}

variable "description" {
  description     = "(Optional ; String ; Default = Same as hostname) Description of the host override."
  type            = string
  default         = null
}

variable "hostname" {
  description     = "(Required ; String) Hostname for the host override without the domain."
  type            = string
}

variable "domain" {
  description     = "(Required ; String) Domain for the host override."
  type            = string
}

variable "ip" {
  description     = "(Required ; String) Target IP for the host override."
  type            = string
}

variable "aliases" {
  description     = "(Required ; Map) Aliases tied to this override"
  type            = map
}