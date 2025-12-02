terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.112"
    }
  }

  backend "azurerm" {
    # This will be configured during initialization
  }
}

provider "azurerm" {
  features {}
}
