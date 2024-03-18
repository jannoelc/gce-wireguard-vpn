output "server_conf" {
  description = "Wireguard server configuration"
  value       = data.wireguard_config_document.server
}

output "client_conf" {
  description = "Wireguard client configurations"
  value       = data.wireguard_config_document.client
}

output "network_cidr" {
  value = data.cidr_network.wg_network.network
}

output "server_ip_address" {
  value = local.server_ip_address
}


