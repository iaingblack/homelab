resource "local_file" "users" {
  filename = "./files/${var.filename}.${var.extension}"
  content  = var.content
}