# win2025-base-ami

Windows Server 2025 AMI base build

```bash
packer init ./packer/build.pkr.hcl
```

Provides code and configuration to build a base Windows Server 2025 AMI

### Powershell

Powershell scripts required to bootstrap the WinRM connection used for Ansible provisioning are stored in the `./powershell` directory and are called during the provisioning step of the Packer build as defined in `./packer/build.pkr.hcl`.

### Packer Variables

All Packer configuration resides in the `./packer` directory and utilises standard Packer configuration syntax.

| Variable                   | Type   | Default                                   | Description                                                                                                                                               |
| -------------------------- | ------ | ----------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ami_account_ids            | string | -                                         | A list of account IDs that have access to launch the resulting AMI(s).                                                                                    |
| ami_name_prefix            | string | `win2025-base`                            | Prefix used for the name tags of resulting AMIs. The version will be appended to this.                                                                    |
| aws_instance_type          | string | `t3.medium`                               | AWS EC2 instance type used when building the AMI.                                                                                                         |
| aws_region                 | string | `eu-west-2`                               | The region in which the AMI will be built.                                                                                                                |
| aws_source_ami_filter_name | string | `Windows_Server-2025-English-Full-Base-*` | Source AMI filter string as per the DescribeImages API documentation. If multiple match, the latest image will be used.                                   |
| aws_source_ami_owner_id    | string | `amazon`                                  | The source AMI owner ID. Used in combination with `aws_source_ami_filter_name` to match the source AMI.                                                   |
| aws_subnet_filter_name     | string | -                                         | Subnet filter string as per the DescribeSubnets API documentation. If multiple match, the subnet with the greatest number of IPv4 addresses will be used. |
| encrypt_boot               | bool   | `false`                                   | Encrypts the bootable EBS volume using the appropriate KMS key.                                                                                           |
| force_delete_snapshot      | bool   | `false`                                   | Automatically delete snapshots associated with AMIs deregistered by `force_deregister`.                                                                   |
| force_deregister           | bool   | `false`                                   | Deregister an existing AMI if one with the same name exists.                                                                                              |
| kms_key_id                 | string | `null`                                    | The Id of the KMS key to use when `encrypt_boot` is enabled. The default KMS key is used if `encrypt_boot` is enabled but a key is not provided.          |
| powershell_path            | string | `../powershell`                           | Relative path to the Powershell scripts.                                                                                                                  |
| root_volume_size_gb        | number | `40`                                      | The EC2 instance root volume size in Gibibytes (GiB).                                                                                                     |
| ssh_private_key_file       | string | `/home/packer/.ssh/packer-builder`        | The path to the common Packer builder private SSH key.                                                                                                    |
| version                    | string | -                                         | Semantic version number for the AMI. Will be automatically appended to `ami_name_prefix` to tag the resulting AMI and snapshots.                          |
| winrm_insecure             | bool   | `true`                                    | Skips validation of the server's SSL certificate for WinRM connections.                                                                                   |
| winrm_timeout              | string | `15m`                                     | Sets the connection timeout value for the WinRM connection.                                                                                               |
| winrm_username             | string | `Administrator`                           | The local username to use for WinRM authentication.                                                                                                       |
| winrm_use_ssl              | bool   | `true`                                    | Connect to WinRM over the HTTPS endpoint on TCP port 5986                                                                                                 |