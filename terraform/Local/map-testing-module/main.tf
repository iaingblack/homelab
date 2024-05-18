module "file-creator" {
  source = "./modules/file-creator"

  for_each = var.files

  filename = each.value.filename
  extension = each.value.extension
  content  = each.value.content
}