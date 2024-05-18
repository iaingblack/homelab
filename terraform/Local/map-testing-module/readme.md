# How to run

```
cd infra
terraform init
terraform plan  -var-file clients/clienta.tfvars
terraform apply -var-file clients/clienta.tfvars -auto-approve
```

# Links

https://github.com/hashicorp/terraform/issues/17179

https://stackoverflow.com/questions/58594506/how-to-for-each-trough-a-listobjects-in-terraform-0-12

https://www.hashicorp.com/blog/terraform-0-12-rich-value-types/