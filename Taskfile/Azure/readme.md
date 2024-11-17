# Create a File Based on Environment

Subscription info is provided with a .env file.

Provide the secrets with an export before running like so.

```
export ARM_CLIENT_SECRET=Add_Secret_Here
export ARM_ACCESS_KEY=Add_Key_Here
```

Then run like this (.env.ib exists, so ENV name to pass is ib), targeting the required Azure Subscription

```
task init    ENV=ib
task plan    ENV=ib VARFILE=bbb.tfvars
task apply   ENV=ib VARFILE=bbb.tfvars
task destroy ENV=ib VARFILE=bbb.tfvars
```