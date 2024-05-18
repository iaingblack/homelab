# Doesnt work
module "file-creator" {
  source = "./modules/file-creator"

  for_each = var.files

  client_type = var.client_type
  filename = each.value.filename
  extension = each.value.extension
  content  = each.value.content
}

data "local_file" "prod-filea" {
  count = var.file_to_data_lookup != "" ? 1 : 0
  filename = var.file_to_data_lookup
}

output "data_read_file_name" {
  value = var.file_to_data_lookup != "" ?  data.local_file.prod-filea[0].id : null
}

output "file_ids" {
  value = module.file-creator.*
}
