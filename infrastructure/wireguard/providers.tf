terraform {
  required_providers {
    cidr = {
      source  = "volcano-coffee-company/cidr"
      version = "0.1.0"
    }

    wireguard = {
      source  = "OJFord/wireguard"
      version = "0.2.1+1"
    }

    filesystem = {
      source  = "wengchaoxi/filesystem"
      version = "0.0.2"
    }
  }
}
