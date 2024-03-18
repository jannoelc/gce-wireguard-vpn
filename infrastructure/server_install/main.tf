resource "ssh_resource" "server" {
  when        = "create"
  host        = var.ssh_host
  user        = var.ssh_user
  private_key = var.ssh_private_key
  timeout     = "4m"
  retry_delay = "5s"

  pre_commands = [
    "sudo apt-get update",
    "sudo apt-get install -y wireguard",
    "sudo apt-get install -y iptables",
  ]

  file {
    content     = "net.ipv4.ip_forward=1"
    destination = "~/sysctl.conf"
  }

  file {
    content     = var.wireguard_conf
    destination = "~/wg0.conf"
  }

  commands = [
    "sudo cp ~/sysctl.conf /etc/sysctl.conf",
    "sudo sysctl -p",
    "rm ~/sysctl.conf",
    "sudo cp ~/wg0.conf /etc/wireguard/wg0.conf",
    "sudo systemctl enable wg-quick@wg0",
    "sudo systemctl start wg-quick@wg0",
    "rm ~/wg0.conf",
  ]
}
