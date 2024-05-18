output "ssh_connection" {
  value = "ssh -i ~/.ssh/ib.ppk root@${hcloud_server.this.ipv4_address}"
}
