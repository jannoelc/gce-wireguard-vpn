terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.44.1"
    }

    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "2.2.0"
    }
  }
}

provider "google" {
  project = var.google["project"]
  region  = var.google["region"]
  zone    = var.google["zone"]
}
