

output "private_key_secret_arn" {
  sensitive   = false
  value       = nonsensitive(tls_private_key.instance.private_key_pem)
  description = "ARN of the Secrets Manager secret containing the private key"
}