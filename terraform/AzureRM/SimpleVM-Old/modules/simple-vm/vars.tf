terragrunt = {
  include {
    path = find_in_parent_folders()
  }
}
variable "prefix" {
  default = ""
}
variable "subscription_id" {
  default = ""
}
variable "vmsize" {
  default ""
}
