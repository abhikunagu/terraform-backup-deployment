terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "terraform-rg"
    storage_account_name = "terraformstate123"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = "fb656642-6401-44d5-9de1-14bda10d53e5"
}

resource "azurerm_resource_group" "example" {
  name     = "terraform-rg"
  location = "East US"
}
