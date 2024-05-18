# How to run

```
cd infra
terraform init
terraform plan  -var-file clients/client-prod.tfvars
terraform apply -var-file clients/client-prod.tfvars -auto-approve
```

# Combine count and for_each

This doesn't work as - The "count" and "for_each" meta-arguments are mutually-exclusive, only one should be used to be explicit about the number of resources to be created

So you cant have a map of DBs and choose to create independently. But you can have a count inside the module on each resource. Workable if you manage a small number of resources.

```terraform
module "file-creator" {
  source = "./modules/file-creator"

  count = var.client_type == "Prod" ? 0 : 1

  for_each = var.files

  client_type = var.client_type
  filename = each.value.filename
  extension = each.value.extension
  content  = each.value.content
}
```