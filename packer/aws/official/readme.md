https://developer.hashicorp.com/packer/tutorials/cloud-production/aws-windows-image

WORKS!

Output

```bash
iain@MacBookPro official % packer build .
learn-packer.amazon-ebs.firstrun-windows: output will be in this color.

==> learn-packer.amazon-ebs.firstrun-windows: Prevalidating any provided VPC information
==> learn-packer.amazon-ebs.firstrun-windows: Prevalidating AMI Name: packer-windows-demo-20251124212856
==> learn-packer.amazon-ebs.firstrun-windows: Found Image ID: ami-0159172a5a821bafd
==> learn-packer.amazon-ebs.firstrun-windows: Creating temporary keypair: packer_6924ce18-541c-738e-2ade-55890d27f1f6
==> learn-packer.amazon-ebs.firstrun-windows: Creating temporary security group for this instance: packer_6924ce1b-bff7-c37a-1900-dbd24322a4e3
==> learn-packer.amazon-ebs.firstrun-windows: Authorizing access to port 5985 from [0.0.0.0/0] in the temporary security groups...
==> learn-packer.amazon-ebs.firstrun-windows: Launching a source AWS instance...
==> learn-packer.amazon-ebs.firstrun-windows: Instance ID: i-0671686b72d03182d
==> learn-packer.amazon-ebs.firstrun-windows: Waiting for instance (i-0671686b72d03182d) to become ready...
==> learn-packer.amazon-ebs.firstrun-windows: Skipping waiting for password since WinRM password set...
==> learn-packer.amazon-ebs.firstrun-windows: Using WinRM communicator to connect: 98.91.27.182
==> learn-packer.amazon-ebs.firstrun-windows: Waiting for WinRM to become available...
==> learn-packer.amazon-ebs.firstrun-windows: WinRM connected.
==> learn-packer.amazon-ebs.firstrun-windows: Connected to WinRM!
==> learn-packer.amazon-ebs.firstrun-windows: Provisioning with Powershell...
==> learn-packer.amazon-ebs.firstrun-windows: Provisioning with powershell script: /var/folders/mv/s5wk8scs6rnbh7vhk444fv1r0000gn/T/powershell-provisioner798262276
==> learn-packer.amazon-ebs.firstrun-windows: HELLO NEW USER; WELCOME TO PACKER
==> learn-packer.amazon-ebs.firstrun-windows: You need to use backtick escapes when using
==> learn-packer.amazon-ebs.firstrun-windows: characters such as DOLLAR$ directly in a command
==> learn-packer.amazon-ebs.firstrun-windows: or in your own scripts.
==> learn-packer.amazon-ebs.firstrun-windows:
==> learn-packer.amazon-ebs.firstrun-windows: Restarting Machine
==> learn-packer.amazon-ebs.firstrun-windows: Waiting for machine to restart...
==> learn-packer.amazon-ebs.firstrun-windows: EC2AMAZ-UNBR5PN restarted.
==> learn-packer.amazon-ebs.firstrun-windows: Machine successfully restarted, moving on
==> learn-packer.amazon-ebs.firstrun-windows: Provisioning with Powershell...
==> learn-packer.amazon-ebs.firstrun-windows: Provisioning with powershell script: ./sample_script.ps1
==> learn-packer.amazon-ebs.firstrun-windows: PACKER_BUILD_NAME is an env var Packer automatically sets for you.
==> learn-packer.amazon-ebs.firstrun-windows: ...or you can set it in your builder variables.
==> learn-packer.amazon-ebs.firstrun-windows: The default for this builder is: firstrun-windows
==> learn-packer.amazon-ebs.firstrun-windows: The PowerShell provisioner will automatically escape characters
==> learn-packer.amazon-ebs.firstrun-windows: considered special to PowerShell when it encounters them in
==> learn-packer.amazon-ebs.firstrun-windows: your environment variables or in the PowerShell elevated
==> learn-packer.amazon-ebs.firstrun-windows: username/password fields.
==> learn-packer.amazon-ebs.firstrun-windows: For example, VAR1 from our config is: A$Dollar
==> learn-packer.amazon-ebs.firstrun-windows: Likewise, VAR2 is: A`Backtick
==> learn-packer.amazon-ebs.firstrun-windows: VAR3 is: A'SingleQuote
==> learn-packer.amazon-ebs.firstrun-windows: Finally, VAR4 is: A"DoubleQuote
==> learn-packer.amazon-ebs.firstrun-windows: None of the special characters needed escaping in the template
==> learn-packer.amazon-ebs.firstrun-windows: Stopping the source instance...
==> learn-packer.amazon-ebs.firstrun-windows: Stopping instance
==> learn-packer.amazon-ebs.firstrun-windows: Waiting for the instance to stop...
==> learn-packer.amazon-ebs.firstrun-windows: Creating AMI packer-windows-demo-20251124212856 from instance i-0671686b72d03182d
==> learn-packer.amazon-ebs.firstrun-windows: Attaching run tags to AMI...
==> learn-packer.amazon-ebs.firstrun-windows: AMI: ami-0d535e4099e9ca02f
==> learn-packer.amazon-ebs.firstrun-windows: Waiting for AMI to become ready...
==> learn-packer.amazon-ebs.firstrun-windows: Skipping Enable AMI deprecation...
==> learn-packer.amazon-ebs.firstrun-windows: Skipping Enable AMI deregistration protection...
==> learn-packer.amazon-ebs.firstrun-windows: Terminating the source AWS instance...
==> learn-packer.amazon-ebs.firstrun-windows: Cleaning up any extra volumes...
==> learn-packer.amazon-ebs.firstrun-windows: No volumes to clean up, skipping
==> learn-packer.amazon-ebs.firstrun-windows: Deleting temporary security group...
==> learn-packer.amazon-ebs.firstrun-windows: Deleting temporary keypair...
Build 'learn-packer.amazon-ebs.firstrun-windows' finished after 8 minutes 10 seconds.

==> Wait completed after 8 minutes 10 seconds

==> Builds finished. The artifacts of successful builds are:
--> learn-packer.amazon-ebs.firstrun-windows: AMIs were created:
us-east-1: ami-0d535e4099e9ca02f
```