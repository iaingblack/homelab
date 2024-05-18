Run the exports

```bash
$ export ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000"
$ export ARM_CLIENT_SECRET=""
$ export ARM_TENANT_ID="10000000-2000-3000-4000-500000000000"

$env:ARM_CLIENT_ID = "00000000-0000-0000-0000-000000000000"
$env:ARM_CLIENT_SECRET = ""
$env:ARM_TENANT_ID = "10000000-2000-3000-4000-500000000000"
```

```bash
terraform init
terraform plan    -var-file clients/prod.tfvars
terraform apply   -var-file clients/prod.tfvars --auto-approve
terraform destroy -var-file clients/prod.tfvars --auto-approve
```
