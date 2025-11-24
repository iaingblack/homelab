packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.3, < 1.4"
    }
  }
}

variable "ami_account_ids" {
  type        = list(string)
  description = "A list of account IDs that have access to launch the resulting AMI(s)"
}

variable "ami_name_prefix" {
  type        = string
  default     = "win2025-base"
  description = "The prefix string that will be used for the name tags of the resulting AMI and snapshot(s); the version string will be appended automatically"
}

variable "aws_instance_type" {
  type        = string
  default     = "t3.medium"
  description = "The EC2 instance type used when building the AMI"
}

variable "aws_region" {
  type        = string
  default     = "eu-west-1"
  description = "The AWS region in which the AMI will be built"
}

variable "version" {
  type        = string
  description = "The semantic version number for the AMI; the version string will be appended automatically to the name tags added to the resulting AMI and snapshot(s)"
  default     = "2025.11.0"
}

variable "aws_source_ami_filter_name" {
  type        = string
  default     = "Windows_Server-2025-English-Full-Base-*"
  description = "The source AMI filter string. Any filter described by the DescribeImages API documentation is valid. If multiple images match then the latest will be used"
}

variable "aws_source_ami_owner_id" {
  type        = string
  description = "The source AMI owner ID; used in combination with aws_source_ami_filter_name to filter for matching source AMIs"
  default     = "amazon"
}

variable "aws_subnet_filter_name" {
  type        = string
  description = "The subnet filter string. Any filter described by the DescribeSubnets API documentation is valid. If multiple subnets match then the one with the most IPv4 addresses free will be used"
}

variable "force_delete_snapshot" {
  type        = bool
  default     = false
  description = "Delete snapshots associated with AMIs, which have been deregistered by force_deregister"
}

variable "force_deregister" {
  type        = bool
  default     = false
  description = "Deregister an existing AMI if one with the same name already exists"
}

variable "kms_key_id" {
  default     = "alias/packer-builders-kms"
  description = "The KMS key ID or alias to use when encrypting the AMI EBS volumes; defaults to the AWS managed key if empty"
  type        = string
}

variable "powershell_path" {
  type        = string
  description = "Path to the build-time powershell scripts"
  default     = "../powershell"
}

variable "root_volume_iops" {
  default     = 3000
  description = "The baseline IOPS for the root EBS volume; 3000 is the gp3 default"
  type        = number
}

variable "root_volume_size_gb" {
  type        = number
  default     = 30
  description = "The EC2 instance root volume size in Gibibytes (GiB)"
}

variable "root_volume_throughput" {
  default     = 125
  description = "The throughput, in MiB/s, for the root EBS volume; 125 is the gp3 default"
  type        = number
}

variable "ssh_private_key_file" {
  type        = string
  default     = "/home/packer/.ssh/packer-builder"
  description = "The path to the common Packer builder private SSH key"
}

variable "winrm_insecure" {
  type        = bool
  description = "Skip validation of the server certificate on WinRM connections (true) or validate (false)"
  default     = true
}

variable "winrm_timeout" {
  type        = string
  description = "Delay before WinRM-HTTPS connections time-out"
  default     = "15m"
}

variable "winrm_username" {
  type        = string
  description = "Username for WinRM connections"
  default     = "Administrator"
}

variable "winrm_use_ssl" {
  type        = bool
  description = "Defines whether to use SSL for WinRM communications (true) or not (false)"
  default     = true
}

source "amazon-ebs" "builder" {
  profile         = "kodekloud"
  ami_name              = "${var.ami_name_prefix}-${var.version}"
  ami_users             = var.ami_account_ids
  force_delete_snapshot = var.force_delete_snapshot
  force_deregister      = var.force_deregister
  imds_support          = "v2.0"
  instance_type         = var.aws_instance_type
  region                = var.aws_region
  ssh_private_key_file  = var.ssh_private_key_file
  ssh_keypair_name      = "packer-builders-${var.aws_region}"
  iam_instance_profile  = "packer-builders-${var.aws_region}"
  user_data_file        = "${var.powershell_path}/winrm_bootstrap.txt"
  

  communicator         = "winrm"
  winrm_insecure       = var.winrm_insecure
  winrm_username       = var.winrm_username
  winrm_use_ssl        = var.winrm_use_ssl

  launch_block_device_mappings {
    delete_on_termination = true
    device_name           = "/dev/sda1"
    encrypted             = true
    iops                  = var.root_volume_iops
    kms_key_id            = var.kms_key_id
    throughput            = var.root_volume_throughput
    volume_size           = var.root_volume_size_gb
    volume_type           = "gp3"
    
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  security_group_filter {
    filters = {
      "group-name": "packer-builders-${var.aws_region}"
    }
  }

  source_ami_filter {
    filters = {
      virtualization-type = "hvm"
      name =  "${var.aws_source_ami_filter_name}"
      root-device-type = "ebs"
    }
    owners = ["${var.aws_source_ami_owner_id}"]
    most_recent = true
  }

  subnet_filter {
    filters = {
      "tag:Name": "${var.aws_subnet_filter_name}"
    }
    most_free = true
    random = false
  }

  run_tags = {
    AMI     = "${var.ami_name_prefix}"
    Name    = "packer-builder-${var.ami_name_prefix}-${var.version}"
    Service = "packer-builder"
  }
  
  run_volume_tags = {
    Builder = "packer-{{packer_version}}"
    Name    = "${var.ami_name_prefix}-${var.version}"
  }

  tags = {
    Builder = "packer-{{packer_version}}"
    Name    = "${var.ami_name_prefix}-${var.version}"
  }
}

build {
  sources = [
    "source.amazon-ebs.builder",
  ]

  provisioner "powershell" {
    inline = [
      # Re-initialise the AWS instance on startup
      "& 'C:/Program Files/Amazon/EC2Launch/ec2launch' reset",
      # Remove system specific information from this image
      "& 'C:/Program Files/Amazon/EC2Launch/ec2launch' sysprep --shutdown",
    ]
  }
}