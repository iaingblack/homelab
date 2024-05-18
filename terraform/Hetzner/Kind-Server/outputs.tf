output "ssh_connection" {
  value = "ssh -i ~/.ssh/ib.ppk root@${hcloud_server.this.ipv4_address}"
}
output "kubeconfig_connection" {
  value = "scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${pathexpand("${local_file.ssh.filename}")} root@${hcloud_server.this.ipv4_address}:/root/.kube/config ~/kind_k8s.config"
}
