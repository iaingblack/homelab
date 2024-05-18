variable "moodys_website_ip_address_whitelist" {
  type        = list(string)
  description = "The IPs to allow access to the website"
  default     = [
    "1.2.3.4"
  ]
}