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
  availability_zone = "${var.region}a"
  tags = {
    Name = "ssm-private-subnet"
  }
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true
  tags = {
    Name = "ssm-public-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "ssm-igw"
  }
}

# Route Table for Public Subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# VPC Endpoints for SSM
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

# Security Group
resource "aws_security_group" "ssm_sg" {
  vpc_id      = aws_vpc.main.id
  name        = "ssm-sg-windows-private"
  description = "Allow HTTPS outbound, RDP, and SSM"
  tags = {
    Name = "ssm-sg-windows-private"
  }
}

# Security Group Rules
resource "aws_security_group_rule" "rdp_ingress" {
  security_group_id = aws_security_group.ssm_sg.id
  type              = "ingress"
  from_port         = 3389
  to_port           = 3389
  protocol          = "tcp"
  cidr_blocks       = ["90.202.240.235/32"]
  description       = "Allow RDP from home IP"
}

resource "aws_security_group_rule" "ssm_ingress" {
  security_group_id = aws_security_group.ssm_sg.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow HTTPS for SSM"
}

resource "aws_security_group_rule" "all_egress" {
  security_group_id = aws_security_group.ssm_sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound traffic"
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

# S3 Bucket for Ansible
resource "aws_s3_bucket" "ansible_bucket" {
  bucket = "ansible-ssm-bucket-${random_string.bucket_suffix.result}"
  tags = {
    Name = "ansible-ssm-bucket"
  }
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Key Pair
resource "tls_private_key" "instance" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "instance" {
  key_name   = "instance-key"
  public_key = tls_private_key.instance.public_key_openssh
}

# EC2 Instance (Windows Server 2022, public subnet, with public IP)
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
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.ssm_sg.id]
  key_name                    = aws_key_pair.instance.key_name
  tags = {
    Name = "SSM-Windows-Public-Instance"
  }
  user_data = <<-EOF
    <powershell>
    Invoke-WebRequest -Uri https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1 -OutFile C:\\ConfigureRemotingForAnsible.ps1
    & C:\\ConfigureRemotingForAnsible.ps1 -EnableCredSSP -ForceNewSSLCert -SkipNetworkProfileCheck
    Write-Output "WinRM configured for Ansible" | Out-File -FilePath C:\\winrm_setup.log
    </powershell>
  EOF
}
