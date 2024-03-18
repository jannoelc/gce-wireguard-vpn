data "google_compute_image" "vm" {
  family  = "ubuntu-minimal-2204-lts"
  project = "ubuntu-os-cloud"
}

resource "google_compute_instance" "vm" {
  name                      = "${var.resource_prefix}-vm"
  machine_type              = "e2-micro"
  tags                      = [var.network_tag]
  can_ip_forward            = true
  allow_stopping_for_update = true

  boot_disk {
    device_name = "server_instance"
    auto_delete = true


    initialize_params {
      image = data.google_compute_image.vm.self_link
      type  = "pd-standard"
      size  = 10
    }
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip       = var.external_ip_address
      network_tier = "STANDARD"
    }
  }

  service_account {
    email  = var.service_account
    scopes = ["cloud-platform"]
  }

  metadata = {
    user-data = var.startup_script
  }
}
