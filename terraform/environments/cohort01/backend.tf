terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  backend "azurerm" {
    resource_group_name = "rg-tfstate-platform"
    container_name      = "tfstate"
    key                 = "cohort01.terraform.tfstate"
    use_oidc            = true
    use_azuread_auth    = true
  }
}

provider "azurerm" {
  features {}
  use_oidc = true
}
