# Set the variable value in *.tfvars file
# or using the -var="hcloud_token=..." CLI option
variable "hcloud_token" {}


variable "ssh_private_key_base64" {
}

variable "server_name" {
}

variable "server_image" {
  default = "ubuntu-24.04"
}

variable "server_size" {
  default = "cx21"
}