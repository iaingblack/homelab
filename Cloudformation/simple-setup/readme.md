# KodeKloud

You need to upload the referenced stack to an s3 bucket... Ughh...

```bash
aws cloudformation validate-template --template-body file://stack.yaml --profile kodekloud
```

```bash
aws ec2 create-key-pair --key-name MyKeyPair --query 'KeyMaterial' --output text > MyKeyPair.pem --profile kodekloud
chmod 400 MyKeyPair.pem

aws cloudformation create-stack --stack-name MyStack --template-body file://stack.yaml --parameters ParameterKey=EnvironmentName,ParameterValue=dev ParameterKey=KeyName,ParameterValue=MyKeyPair --capabilities CAPABILITY_NAMED_IAM --profile kodekloud --disable-rollback

aws cloudformation delete-stack --stack-name MyStack --profile kodekloud
```

Drift
```bash
aws cloudformation detect-stack-drift --profile kodekloud
```



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