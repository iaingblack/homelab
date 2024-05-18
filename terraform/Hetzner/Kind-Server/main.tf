
# Configure the Hetzner Cloud Provider
provider "hcloud" {
  token = var.hcloud_token
}
locals {
  local_ppk_filename = "key.ppk"
}

resource "local_file" "ssh" {
  content_base64  = var.ssh_private_key_base64
  filename = local.local_ppk_filename
  file_permission = "0600"
}

resource "hcloud_network" "network" {
  name     = "network"
  ip_range = "10.0.0.0/16"
}
resource "hcloud_network_subnet" "network-subnet" {
  type         = "cloud"
  network_id   = hcloud_network.network.id
  network_zone = "eu-central"
  ip_range     = "10.0.1.0/24"
}

# Create a server
resource "hcloud_server" "this" {
  name        = "kind-server"
  image       = "ubuntu-22.04"
  server_type = var.size
  datacenter  = "fsn1-dc14"
  ssh_keys    = ["IB_SSH"]

  provisioner "file" {
    source = "scripts/setup-kind.sh"
    destination = "/tmp/script.sh"
    connection {
      type        = "ssh"
      user        = "root"
      private_key = file(pathexpand("${local_file.ssh.filename}"))
      host        = hcloud_server.this.ipv4_address
    }
  }
  provisioner "remote-exec" {
    inline = [
      "apt update -y",
      "chmod +x /tmp/script.sh",
      "/tmp/script.sh"
    ]
    connection {
      type        = "ssh"
      user        = "root"
      private_key = file(pathexpand("${local_file.ssh.filename}"))
      host        = hcloud_server.this.ipv4_address
    }
  }

  network {
    network_id = hcloud_network.network.id
    ip         = "10.0.1.5"
    alias_ips = [
      "10.0.1.6",
      "10.0.1.7"
    ]
  }
  depends_on = [
    hcloud_network_subnet.network-subnet
  ]
}

data "template_file" "kind-config" {
  template = "${file("${path.module}/templates/kind-config.yaml.template")}"
  vars = {
    ipv4_address = "${hcloud_server.this.ipv4_address}"
  }
}

resource "null_resource" "create-kind-cluster" {
  provisioner "remote-exec" {
    inline = [
      "echo \"${data.template_file.kind-config.rendered}\" > /tmp/k8s.yaml",
      "kind create cluster --config=/tmp/k8s.yaml",
      "cat .kube/config",
    ]
    connection {
      type        = "ssh"
      user        = "root"
      private_key = file(pathexpand("${local_file.ssh.filename}"))
      host        = hcloud_server.this.ipv4_address
    }
  }
}

resource "null_resource" "get-kube-config" {
  provisioner "local-exec" {
    # Because we use an ipaddress tp connect to oir instance, ignore certificate mismatch errors
    command = "scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${pathexpand("${local_file.ssh.filename}")} root@${hcloud_server.this.ipv4_address}:/root/.kube/config ~/kind_k8s.config"
  }
  depends_on = [
    null_resource.create-kind-cluster
  ]
}
