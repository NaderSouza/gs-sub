terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.77.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "nader-gs"
    storage_account_name = "nadergs"
    container_name       = "load"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  use_msi                    = true
}