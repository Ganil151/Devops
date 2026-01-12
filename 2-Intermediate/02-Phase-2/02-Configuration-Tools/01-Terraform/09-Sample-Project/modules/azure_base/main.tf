# Azure Base Module

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

resource "azurerm_resource_group" "base" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "base" {
  name                = "${var.resource_group_name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.base.location
  resource_group_name = azurerm_resource_group.base.name
}

resource "azurerm_subnet" "base" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.base.name
  virtual_network_name = azurerm_virtual_network.base.name
  address_prefixes     = ["10.0.2.0/24"]
}
