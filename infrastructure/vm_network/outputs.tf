output "external_ip_address" {
  value = google_compute_address.static_addr.address
}

output "network_tag" {
  value = local.network_tag
}
