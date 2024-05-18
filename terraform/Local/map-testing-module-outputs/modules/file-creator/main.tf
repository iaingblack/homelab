variable "filename"    { type = string }
variable "extension"   { type = string }
variable "content"     { type = string }
variable "client_type" { type = string }

#######################
# If not using count
#######################
#resource "local_file" "this" {
#  count     = var.client_type == "dr" ? 0 : 1
#  filename = "./files/${var.client_type}-${var.filename}.${var.extension}"
#  content  = var.content
#}
#
#output "id" {
#  value = local_file.this.id
#}

#######################
# If using count
#######################
resource "local_file" "this" {
  count     = var.client_type == "dr" ? 0 : 1
  filename = "./files/${var.client_type}-${var.filename}.${var.extension}"
  content  = var.content
}

output "id" {
  value = one(local_file.this[*].id)
}