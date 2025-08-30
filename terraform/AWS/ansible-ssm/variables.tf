variable "projectName" {
  description = "The name of the project"
  type        = string
}
variable "envName" {
  description = "The name of the environment"
  type        = string
}
variable "aws_profile" {
  description = "The AWS profile to use"
  type        = string
}
variable "region" {
  description = "The AWS region to use"
  type        = string
}