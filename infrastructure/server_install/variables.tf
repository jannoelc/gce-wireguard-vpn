variable "ssh_user" {
  description = "SSH user"
  type        = string
}

variable "ssh_host" {
  description = "SSH host"
  type        = string
}

variable "ssh_private_key" {
  description = "SSH private key"
  type        = string
  sensitive   = true
}

variable "wireguard_conf" {
  description = "Wireguard configuration"
  type        = string
  sensitive   = true
}
