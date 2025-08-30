# Outputs
output "instance_id" {
  value = aws_instance.example.id
}

output "public_ip" {
  value = aws_instance.example.public_ip
}

output "ansible_bucket_name" {
  value = aws_s3_bucket.ansible_bucket.id
}

output "private_key_secret_arn" {
  sensitive   = false
  value       = nonsensitive(tls_private_key.instance.private_key_pem)
  description = "ARN of the Secrets Manager secret containing the private key"
}
