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


# State Change

Note, this does not apply locally, it seems to either know, or always is correctly init'd to know when you change a terraform version. The below seems to happen on an Azure backend when you change terraform version.

## Steps 

Run the following with terraform v 1.2.9 (my default)

```bash
terraform init 
terraform plan    
terraform apply --auto-approveas
```

Then with v1.4.6

If we try a plan with a new terraform versions it realises something odd is happening

```bash
terraform_146 plan
```

```text
│ Changes to backend configurations require reinitialization. This allows
│ Terraform to set up the new configuration, copy existing state, etc. Please run
│ "terraform init" with either the "-reconfigure" or "-migrate-state" flags to
│ use the current configuration.
│
│ If the change reason above is incorrect, please verify your configuration
│ hasn't changed and try again. At this point, no changes to your existing
│ configuration or state have been made.
```

Which means (https://developer.hashicorp.com/terraform/cli/commands/init)

```azure
Re-running init with an already-initialized backend will update the working directory to use the new backend settings. Either -reconfigure or -migrate-state must be supplied to update the backend configuration.

The -migrate-state option will attempt to copy existing state to the new backend, and depending on what changed, may result in interactive prompts to confirm migration of workspace states. The -force-copy option suppresses these prompts and answers "yes" to the migration questions. Enabling -force-copy also automatically enables the -migrate-state option.

The -reconfigure option disregards any existing configuration, preventing migration of any existing state.
```

So, rerun init

```bash
terraform_146 init
```

Get this more specific error

```text
│ If you wish to attempt automatic migration of the state, use "terraform init -migrate-state".
│ If you wish to store the current configuration with no changes to the state, use "terraform init -reconfigure".
```

So try migrate state

```bash
terraform_146 init -migrate-state
```

And... 

```text
│ Error: Failed to decode current backend config
│
│ The backend configuration created by the most recent run of "terraform init" could not be decoded: unsupported attribute "use_microsoft_graph". The configuration may have been initialized by an earlier version that used an        
│ incompatible configuration structure. Run "terraform init -reconfigure" to force re-initialization of the backend.
```

Let's try reconfigure instead

```text
Initializing the backend...

Successfully configured the backend "azurerm"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...
- Reusing previous version of hashicorp/azurerm from the dependency lock file
- Using previously-installed hashicorp/azurerm v3.56.0
```

It now works

```bash
> terraform_146 plan
             
azurerm_resource_group.this: Refreshing state... [id=/subscriptions/0c269579-ef66-4135-a0b0-2accafb8f99c/resourceGroups/Test]

No changes. Your infrastructure matches the configuration.
```

But, the state file has not changed yet, it is still Terraform 1.2.9

```json
{
  "version": 4,
  "terraform_version": "1.2.9",
  "serial": 1,
  "lineage": "c4742620-7ae2-5c41-803d-89d680c5cdbb",
  "...": "....."
}
```

Apply the change

```bash
terraform_146 apply

azurerm_resource_group.this: Refreshing state... [id=/subscriptions/0c269579-ef66-4135-a0b0-2accafb8f99c/resourceGroups/Test]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.
Releasing state lock. This may take a few moments...

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
```

Nothing happened. But, the state file updated

```text
{
  "version": 4,
  "terraform_version": "1.4.6",
  "serial": 2,
  "lineage": "c4742620-7ae2-5c41-803d-89d680c5cdbb",
  "...": "....."
}  
```