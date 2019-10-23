terraform {
  backend "azurerm" {
    storage_account_name = "account name"
    container_name       = "tfstate-modular"
    key                  = "script.terraform.tfstate"
  }
}