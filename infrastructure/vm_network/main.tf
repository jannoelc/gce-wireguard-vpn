locals {
  network_tag = var.resource_prefix
}

resource "google_compute_firewall" "firewall" {
  name          = "${var.resource_prefix}-firewall"
  network       = "default"
  direction     = "INGRESS"
  priority      = 1000
  target_tags   = [local.network_tag]
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "udp"
    ports    = [var.udp_port]
  }
}

resource "google_compute_address" "static_addr" {
  name         = "${var.resource_prefix}-static-addr"
  address_type = "EXTERNAL"
  network_tier = "STANDARD"
}
