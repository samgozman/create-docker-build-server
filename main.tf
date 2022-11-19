terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
    }
  }
  required_version = ">= 1.3.4"
}

# Hetzner Cloud Provider documentation:
# https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs

#! Create .auto.tfvars file with the following content:
# hcloud_token = "<your_hetzner_api_key>"
variable "hcloud_token" {}

variable "os_type" {
  default = "ubuntu-22.04"
}

variable "datacenter" {
  default = "nbg1-dc3"
}

provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_ssh_key" "default" {
  name       = "hetzner_key"
  public_key = file("~/.ssh/id_rsa.pub")
}

# Create static IP address
resource "hcloud_primary_ip" "public" {
  name          = "public_ip"
  datacenter    = var.datacenter
  type          = "ipv4"
  assignee_type = "server"
  auto_delete   = false
}

# Create firewall
resource "hcloud_firewall" "firewall" {
  name = "ssh-only-firewall"
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
}

# Create server
resource "hcloud_server" "builder" {
  count       = 1
  name        = "docker-builder"
  image       = var.os_type
  server_type = "cpx21"
  datacenter  = var.datacenter
  ssh_keys    = [hcloud_ssh_key.default.id]
  backups     = false
  public_net {
    ipv4_enabled = true
    ipv4         = hcloud_primary_ip.public.id
  }
  firewall_ids = [hcloud_firewall.firewall.id]
  user_data = file("cloud-config.yml")
}

# Otput server IP
output "builder_ip" {
  value = {
    for server in hcloud_server.builder :
    server.name => server.ipv4_address
  }
}
