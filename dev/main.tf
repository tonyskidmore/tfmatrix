resource "random_string" "random" {
  length           = 4
  special          = true
  override_special = "/@£$"
}
