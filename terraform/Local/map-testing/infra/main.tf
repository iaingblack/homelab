resource "local_file" "users" {
  for_each = var.files

  filename = "${each.value.filename}.bar"
  content  = each.value.content
}