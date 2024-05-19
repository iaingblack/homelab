# Set the variable value in *.tfvars file
# or using the -var="hcloud_token=..." CLI option
variable "hcloud_token" {}

variable "server_size" {
  default = "cx21"
}

variable "ssh_private_key_base64" {
}

variable "server_name" {
  default = "ubuntu-server"
}

variable "server_image" {
  default = "ubuntu-24.04"
}