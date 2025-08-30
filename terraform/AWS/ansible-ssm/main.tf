# VPC and Private Subnet
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${local.resource_prefix}-vpc"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.region}a" # Adjust AZ as needed
  tags = {
    Name = "ssm-private-subnet"
  }
}

# VPC Endpoints for SSM (no internet required)
resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.eu-west-2.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private.id]
  security_group_ids  = [aws_security_group.ssm_sg.id]
  private_dns_enabled = true
  tags = {
    Name = "ssm-endpoint"
  }
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.eu-west-2.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private.id]
  security_group_ids  = [aws_security_group.ssm_sg.id]
  private_dns_enabled = true
  tags = {
    Name = "ssmmessages-endpoint"
  }
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.eu-west-2.ec2messages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private.id]
  security_group_ids  = [aws_security_group.ssm_sg.id]
  private_dns_enabled = true
  tags = {
    Name = "ec2messages-endpoint"
  }
}

# Security Group (HTTPS outbound to endpoints only)
resource "aws_security_group" "ssm_sg" {
  vpc_id      = aws_vpc.main.id
  name        = "ssm-sg-windows-private"
  description = "Allow HTTPS outbound to SSM endpoints"

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["90.202.240.235/32"] # For endpoints; no public inbound needed
  }
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # For endpoints; no public outbound needed
  }

  # No inbound needed for SSM
}

# IAM Role for SSM
resource "aws_iam_role" "ssm_role" {
  name = "ec2-ssm-role-windows-private"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "ec2-ssm-profile-windows-private"
  role = aws_iam_role.ssm_role.name
}

# S3 Bucket for Ansible File Transfers (required by aws_ssm plugin)
resource "aws_s3_bucket" "ansible_bucket" {
  bucket = "ansible-ssm-bucket-${random_string.bucket_suffix.result}" # Unique name
  tags = {
    Name = "ansible-ssm-bucket"
  }
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "tls_private_key" "instance" {
  algorithm = "RSA"
  rsa_bits  = 2048
}
resource "aws_key_pair" "instance" {
  key_name   = "instance-key"
  public_key = tls_private_key.instance.public_key_openssh
}

# EC2 Instance (Windows Server 2022, private subnet, no public IP)
data "aws_ami" "windows" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "example" {
  ami                         = data.aws_ami.windows.id
  instance_type               = "t3.medium"
  iam_instance_profile        = aws_iam_instance_profile.ssm_profile.name
  subnet_id                   = aws_subnet.private.id
  associate_public_ip_address = false # No public IP
  vpc_security_group_ids      = [aws_security_group.ssm_sg.id]
  key_name                    = aws_key_pair.instance.key_name

  tags = {
    Name = "SSM-Windows-Private-Instance"
  }

  # User data: Enable WinRM for Ansible (download and run script)
  user_data = <<-EOF
    <powershell>
    # Download and run Ansible WinRM setup script
    Invoke-WebRequest -Uri https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1 -OutFile C:\\ConfigureRemotingForAnsible.ps1
    & C:\\ConfigureRemotingForAnsible.ps1 -EnableCredSSP -ForceNewSSLCert -SkipNetworkProfileCheck

    # Optional: Custom setup
    Write-Output "WinRM configured for Ansible" | Out-File -FilePath C:\\winrm_setup.log
    </powershell>
  EOF
}