# Local Run

```bash
export TF_VAR_hcloud_token=""
export TF_VAR_ssh_private_key_base64=""

terraform init  -backend-config "key=hetzner/Hetzner-BuildServer.tfstate" -var-file="./envs/buildserver.tfvars"
terraform plan  -var-file="./envs/buildserver.tfvars"
terraform apply -var-file="./envs/buildserver.tfvars" 
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