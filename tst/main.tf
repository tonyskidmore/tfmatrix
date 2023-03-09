resource "random_string" "random" {
  length           = 9
  special          = true
  override_special = "/@£$"
}
