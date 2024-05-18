variable "apiKey" {
  type = string
}

variable "space" {
  type = string
}

variable "serverURL" {
  type = string
}

variable "files" {
  type = map(object({
    name = string
    pause = number
  }))
  default = { z = { name = "envz", pause = -1 }}
}