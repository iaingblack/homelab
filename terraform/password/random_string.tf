# If a string exists its values will be ignored.
# If a string does not exist, the password values will be generated.

resource "random_string" "test" {
  length  = 16
  special = true
  min_special = 1
  lifecycle {
    ignore_changes = [length, special, min_special]
  }
}

output "random_string" {
  value = random_string.test.result
}
