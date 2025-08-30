# KodeKloud

Launch a Terraform + AWS playground. Extend it immediately.

https://kodekloud.com/playgrounds/playground-terraform-aws

On the remote terminal
```bash
cat ../.aws/credentials
```

On your machine

```bash
aws configure --profile kodekloud

aws_access_key_id
aws_secret_access_key
eu-west-2
```

Do a task clean

```bash
task clean
task init
task plan ENV=enva
```

I had a weird issue where I have to name what profile I am using, so i've hardcoded it as kodekloud and its in the env file and referenced

Done!