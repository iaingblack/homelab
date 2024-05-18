resource "local_file" "this" {
  count = var.client_type == "dr" ? 0 : 1
  filename = "./files/${var.client_type}-${var.filename}.${var.extension}"
  content  = var.content
}
