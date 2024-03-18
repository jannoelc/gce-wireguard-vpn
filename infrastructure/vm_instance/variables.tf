variable "resource_prefix" {
  type = string
}

variable "external_ip_address" {
  type = string
}

variable "service_account" {
  type = string
}

variable "network_tag" {
  type = string
}

variable "startup_script" {
  type     = string
  default  = null
  nullable = true
}

