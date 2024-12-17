# Create a File Based on Environment

Subscription info is provided with a .env file.

Provide the secrets with an export before running like so.

```
export ARM_CLIENT_SECRET=Add_Secret_Here
export ARM_ACCESS_KEY=Add_Key_Here
```

Then run like this (.env.testing exists, so ENV name to pass is testing), targeting the required Azure Subscription

```
export ARM_ACCESS_KEY=Add_Key_Here
task init         ENV=testing
task plan         ENV=testing VARFILE=bbb.tfvars
task apply        ENV=testing VARFILE=bbb.tfvars
task auto-apply   ENV=testing VARFILE=bbb.tfvars
task destroy      ENV=testing VARFILE=bbb.tfvars
task auto-destroy ENV=testing VARFILE=bbb.tfvars
task clean

export ARM_ACCESS_KEY=Add_Key_Here
task init         ENV=rootisgod
task plan         ENV=rootisgod VARFILE=bbb.tfvars
task apply        ENV=rootisgod VARFILE=bbb.tfvars
task auto-apply   ENV=rootisgod VARFILE=bbb.tfvars
task destroy      ENV=rootisgod VARFILE=bbb.tfvars
task auto-destroy ENV=rootisgod VARFILE=bbb.tfvars
```