resource "random_string" "random" {
  length           = 10
  special          = true
  override_special = "/@£$"
}
