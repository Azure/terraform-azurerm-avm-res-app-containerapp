terraform {
  required_version = ">= 1.3"

  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.85, < 4.0"
    }
    modtm = {
      source  = "Azure/modtm"
      version = ">= 0.3.2, < 1.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}