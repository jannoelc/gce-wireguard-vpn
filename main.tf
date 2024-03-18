resource "random_string" "random_hash" {
  length  = 8
  upper   = false
  special = false
}

locals {
  name                  = "doge-${random_string.random_hash.result}"
  prefix                = local.name
  ipv4_address          = "192.168.69.1"
  wireguard_listen_port = "51820"
  wireguard_config_path = "./wireguard"
}

data "cloudinit_config" "conf" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content      = <<EOT
#cloud-config

apt:
  sources:
    docker.list:
      source: deb [arch=amd64] https://download.docker.com/linux/ubuntu $RELEASE stable
      keyid: 9DC858229FC7DD38854AE2D88D81803C0EBFCD88

packages:
  - apt-transport-https
  - ca-certificates
  - curl
  - gnupg-agent
  - software-properties-common
  - docker-ce
  - docker-ce-cli
  - containerd.io

# Enable ipv4 forwarding, required on CIS hardened machines
write_files:
  - path: /etc/sysctl.d/enabled_ipv4_forwarding.conf
    content: |
      net.ipv4.conf.all.forwarding=1

# create the docker group
groups:
  - docker

# Add default auto created user to docker group
system_info:
  default_user:
    groups: [docker]
EOT
    filename     = "conf.yaml"
  }
}

module "vm_network" {
  source = "./infrastructure/vm_network"
  providers = {
    google = google
  }

  resource_prefix = local.prefix
  udp_port        = local.wireguard_listen_port
}

# Wireguard
module "wireguard" {
  source = "./infrastructure/wireguard"

  ipv4_address            = local.ipv4_address
  server_external_host    = module.vm_network.external_ip_address
  server_listen_port      = local.wireguard_listen_port
  client_conf_output_path = local.wireguard_config_path
}

data "google_compute_default_service_account" "default" {}

resource "google_service_account" "vm" {
  account_id = "${local.prefix}-account"
}

resource "google_storage_bucket" "server_config" {
  name          = "${local.prefix}-bucket"
  location      = var.google["region"]
  force_destroy = true

  public_access_prevention = "enforced"
}

data "google_iam_policy" "server_config" {
  binding {
    role    = "roles/storage.admin"
    members = ["serviceAccount:${data.google_compute_default_service_account.default.email}"]
  }

  binding {
    role    = "roles/storage.objectViewer"
    members = ["serviceAccount:${google_service_account.vm.email}"]
  }
}

resource "google_storage_bucket_iam_policy" "policy" {
  bucket      = google_storage_bucket.server_config.name
  policy_data = data.google_iam_policy.server_config.policy_data
}

resource "google_storage_bucket_object" "wireguard_conf" {
  name    = "${local.prefix}-wg0.conf"
  bucket  = google_storage_bucket.server_config.name
  content = module.wireguard.server_conf.conf
}

# VM
module "vm_instance" {
  source = "./infrastructure/vm_instance"
  providers = {
    google = google
  }

  resource_prefix     = local.prefix
  external_ip_address = module.vm_network.external_ip_address
  network_tag         = module.vm_network.network_tag
  service_account     = google_service_account.vm.email
  startup_script = data.cloudinit_config.conf.rendered
}
