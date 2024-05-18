variable "client_type" {
  type = string
}

variable "files" {
  type = map(object({
    filename = string
    extension = string
    content  = string
  }))
  default = { clienta = { filename = "filea", extension = "txt", content  = "blah AAAAA" }}
}

variable "file_to_data_lookup" {
  type = string
  default = ""
}