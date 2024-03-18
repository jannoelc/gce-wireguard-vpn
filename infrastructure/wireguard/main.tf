data "cidr_network" "wg_network" {
  ip   = var.ipv4_address
  mask = "255.255.255.0"
}

resource "wireguard_asymmetric_key" "server" {}

resource "wireguard_asymmetric_key" "client" {}

resource "wireguard_preshared_key" "client" {}

locals {
  server_ip_address = cidrhost(data.cidr_network.wg_network.network, 1)
  client_ip_address = cidrhost(data.cidr_network.wg_network.network, 2)
}

data "wireguard_config_document" "server" {
  private_key = wireguard_asymmetric_key.server.private_key
  addresses   = [local.server_ip_address]
  listen_port = var.server_listen_port
  post_up = [
    "iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE"
  ]
  post_down = [
    "iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE"
  ]

  peer {
    public_key           = wireguard_asymmetric_key.client.public_key
    preshared_key        = wireguard_preshared_key.client.key
    allowed_ips          = [local.client_ip_address]
    persistent_keepalive = 25
  }
}

data "wireguard_config_document" "client" {
  private_key = wireguard_asymmetric_key.client.public_key
  addresses   = [local.client_ip_address]

  peer {
    public_key    = wireguard_asymmetric_key.server.public_key
    preshared_key = wireguard_preshared_key.client.key
    endpoint      = "${var.server_external_host}:${var.server_listen_port}"
    allowed_ips   = [data.cidr_network.wg_network.network]
  }
}

resource "filesystem_file" "writer" {
  path    = "${var.client_conf_output_path}/wg0.conf"
  content = data.wireguard_config_document.client.conf
}

resource "filesystem_file" "writer2" {
  path    = "${var.client_conf_output_path}/server.conf"
  content = data.wireguard_config_document.server.conf
}
