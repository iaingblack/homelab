variable "files" {
  type = map(object({
    filename = string
    extension = string
    content  = string
  }))
}