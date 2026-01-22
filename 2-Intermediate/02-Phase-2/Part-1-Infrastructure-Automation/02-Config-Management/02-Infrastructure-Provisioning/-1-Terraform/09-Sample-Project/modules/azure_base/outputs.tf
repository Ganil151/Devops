output "resource_group_id" {
  value = azurerm_resource_group.base.id
}

output "vnet_name" {
  value = azurerm_virtual_network.base.name
}

output "subnet_id" {
  value = azurerm_subnet.base.id
}
