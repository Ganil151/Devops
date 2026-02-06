# Azure Front Door & DNS Reference

Azure Front Door is a modern cloud Content Delivery Network (CDN) that provides fast, reliable, and secure access between your users and your applications' static and dynamic web content.

## 🚀 Key Features
- **Global Load Balancing**: Split-TCP based Anycast protocol to ensure users connect to the nearest POP.
- **SSL Offloading**: Centralized certificate management and encryption at the edge.
- **WAF Integration**: Integrated Web Application Firewall to block Layer 7 attacks.

## 🛠️ IaC (Terraform)
```hcl
resource "azurerm_cdn_frontdoor_profile" "fd" {
  name                = "fd-prod-001"
  resource_group_name = "rg-network"
  sku_name            = "Standard_AzureFrontDoor"
}
```
