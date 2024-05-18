# Local Run

```bash
export TF_VAR_hcloud_token=""
export TF_VAR_ssh_private_key_base64=""

terraform init
terraform plan
terraform apply
terraform apply -auto-approve
terraform destroy -auto-approve
```

```bash
ssh -i ~/.ssh/ib.ppk root@ipv4address
```

# Links

## Terraform Cloud

https://app.terraform.io/app/organizations

## Hetzner

https://console.hetzner.cloud/projects