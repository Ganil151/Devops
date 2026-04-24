# Azure VNet & ExpressRoute Reference

Azure Virtual Network (VNet) is the fundamental building block for your private network in Azure.

## 🏗️ Key Features
- **Isolaton**: VNets are regional assets.
- **Subnets**: Logical divisions (e.g., GateWaySubnet, DMZ, Backend).
- **VNet Peering**: Low-latency connectivity between different VNets.
- **ExpressRoute**: Private, dedicated connections to Azure.

## 🛡️ Security
- **NSG (Network Security Groups)**: Stateful rule sets for traffic control at the subnet or NIC level.
- **ASG (Application Security Groups)**: Grouping VMs by role to simplify NSG management.

## 🛠️ IaC (Terraform)
```hcl
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-prod-001"
  address_space       = ["10.0.0.0/16"]
  location            = "eastus"
  resource_group_name = "rg-network"
}
```
