Run the exports

```bash
$ export ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000"
$ export ARM_CLIENT_SECRET=""
$ export ARM_TENANT_ID="10000000-2000-3000-4000-500000000000"

$env:ARM_CLIENT_ID = "00000000-0000-0000-0000-000000000000"
$env:ARM_CLIENT_SECRET = ""
$env:ARM_TENANT_ID = "10000000-2000-3000-4000-500000000000"
$env:ARM_ACCESS_KEY = "blah_blah" 
```

```bash
terraform init 
terraform plan    
terraform apply   --auto-approve
terraform destroy --auto-approve
```
