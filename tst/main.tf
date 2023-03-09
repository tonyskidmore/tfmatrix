resource "random_string" "random" {
  length           = 8
  special          = true
  override_special = "/@£$"
}
