resource "random_string" "random" {
  length           = 7
  special          = true
  override_special = "/@£$"
}
