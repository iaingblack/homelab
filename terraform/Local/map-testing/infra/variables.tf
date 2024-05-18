variable "files" {
  type = map(object({
    filename = string
    content  = string
  }))
}