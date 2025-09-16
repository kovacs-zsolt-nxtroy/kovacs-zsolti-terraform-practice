terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "~> 1.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Data source for existing Resource Group
data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

# Data source for existing Key Vault (if specified)
data "azurerm_key_vault" "existing" {
  count               = var.key_vault_name != "" ? 1 : 0
  name                = var.key_vault_name
  resource_group_name = var.key_vault_resource_group_name != "" ? var.key_vault_resource_group_name : data.azurerm_resource_group.main.name
}


