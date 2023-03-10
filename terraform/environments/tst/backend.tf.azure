terraform {
  backend "azurerm" {
    resource_group_name   = "rg-terraform-state"
    storage_account_name  = "satfbackendstate123tst"
    container_name        = "tfstate"
    key                   = "terraform.tfstate"
  }
}