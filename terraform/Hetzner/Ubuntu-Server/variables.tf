# Set the variable value in *.tfvars file
# or using the -var="hcloud_token=..." CLI option
variable "hcloud_token" {}

variable "size" {
  default = "cx21"
}

variable "ssh_private_key_base64" {
}
