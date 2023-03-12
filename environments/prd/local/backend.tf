terraform {
  backend "local" {
    path = "prd/terraform.tfstate"
  }
}