variable "client_type" { type = string }
variable "files" { type = map(object({ filename = string, extension = string, content  = string })) }

module "file-creator" {
  source = "./modules/file-creator"
  for_each = var.files
  client_type = var.client_type
  filename = each.value.filename
  extension = each.value.extension
  content  = each.value.content
}

# Outputs all the info about what was passed for output
output "all_file_info" {
  value = module.file-creator[*]
}

# Outputs a single named key id
output "single_file_id" {
  value = module.file-creator["clienta"].id
}

# Outputs just the new file ids as a set (nt sure why, but the example showed this)
output "all_file_ids_toset" {
  value = toset([
    for  file_id in module.file-creator : file_id.id
  ])
}

# Outputs just the new file ids
# https://www.reddit.com/r/Terraform/comments/jyz0dm/working_with_for_each_for_outputs_in_modules/
output "all_file_ids_as_list" {
  value = [
    for files_id in module.file-creator : files_id.id
  ]
}
