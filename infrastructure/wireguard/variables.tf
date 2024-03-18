variable "ipv4_address" {
  description = "IP address"
  type        = string
}

variable "server_external_host" {
  description = "Wireguard external host"
  type        = string
}

variable "server_listen_port" {
  type = string
}

variable "client_conf_output_path" {
  description = "Path wherein client configurations will be written. Does not write if not provided"
  type        = string
  default     = null
}

