# 🌐 Lab: The 3-Cloud VPN Mesh (AWS + Azure + GCP)

> **Scenario**: Your organization requires a resilient, low-latency private network connecting core services in AWS (VPC), Azure (VNet), and GCP (VPC).
> **Requirement**: Use BGP (Border Gateway Protocol) for dynamic routing to ensure that if one link fails, traffic can "hop" through the third cloud (e.g., AWS -> Azure -> GCP).

---

## 🏗️ The Topology

```text
      [ AWS VPC ]
       /      \
      /        \ (BGP VPN)
 (BGP VPN)      \
    /        [ Azure VNet ]
   /           /
[ GCP VPC ]---/ (BGP VPN)
```

---

## 🛠️ Step 1: AWS Configuration (The Hub)

We use Terraform to define the AWS side of the mesh.

### 1. Customer Gateways (Representing Azure & GCP)
```hcl
resource "aws_customer_gateway" "azure" {
  bgp_asn    = 65515 # Azure's default ASN
  ip_address = var.azure_vpn_public_ip
  type       = "ipsec.1"
}

resource "aws_customer_gateway" "gcp" {
  bgp_asn    = 16550 # GCP's default ASN
  ip_address = var.gcp_vpn_public_ip
  type       = "ipsec.1"
}
```

### 2. VPN Gateway & BGP Propagation
```hcl
resource "aws_vpn_gateway" "mesh_gw" {
  vpc_id = aws_vpc.main.id
  amazon_side_asn = 64512 # AWS ASN
}

resource "aws_vpn_connection" "to_azure" {
  vpn_gateway_id      = aws_vpn_gateway.mesh_gw.id
  customer_gateway_id = aws_customer_gateway.azure.id
  type                = "ipsec.1"
  static_routes_only  = false # Enable BGP
}
```

---

## 🛠️ Step 2: Azure Configuration

Azure uses a **Virtual Network Gateway**.

```hcl
resource "azurerm_public_ip" "vpn_ip" { ... }

resource "azurerm_virtual_network_gateway" "to_aws" {
  name                = "azure-to-aws-gw"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  type     = "Vpn"
  vpn_type = "RouteBased"
  sku      = "VpnGw1"

  bgp_settings {
    asn = 65515
  }

  ip_configuration {
    public_ip_address_id = azurerm_public_ip.vpn_ip.id
    ...
  }
}
```

---

## 🛠️ Step 3: GCP Configuration (Cloud Router)

GCP relies on the **Cloud Router** to manage BGP sessions.

```hcl
resource "google_compute_router" "router" {
  name    = "gcp-mesh-router"
  network = google_compute_network.vpc.name
  bgp {
    asn = 16550
  }
}

resource "google_compute_vpn_tunnel" "tunnel_to_aws" {
  name               = "gcp-to-aws-tunnel"
  peer_ip            = var.aws_vpn_public_ip
  shared_secret      = var.vpn_secret
  target_vpn_gateway = google_compute_vpn_gateway.target_gw.id
  router             = google_compute_router.router.name
}
```

---

## 🧪 Verification: The "Routing Hop" Test

Once the tunnels are UP, check the BGP learned routes.

| Cloud | Local Route | Learned via Azure | Learned via GCP |
|:---|:---|:---|:---|
| **AWS** | `10.0.0.0/16` | `10.1.0.0/16` | `10.2.0.0/16` |
| **Azure** | `10.1.0.0/16` | - | `10.2.0.0/16` (via BGP hop) |

**The Resilience Test**: 
1. Manually shut down the **Azure <-> GCP** tunnel.
2. Ping a GCP instance from an Azure VM.
3. Traffic should now flow: **Azure -> AWS -> GCP**.

---

## 🚨 Principal Architect Insights

- **MTU Issues**: Cloud VPNs often have an MTU of 1400 or 1350 bytes. Ensure your instances use **TCP MSS Clamping** to avoid dropped packets on large payloads.
- **Cost Implications**: You are paying for egress from ALL clouds involved. A multi-cloud mesh is expensive; only use it for control-plane traffic or critical metadata.
- **BGP Multi-Exit Discriminator (MED)**: Use MED to prefer one cloud over another as the primary "transit" hub if necessary.

---
**Module**: Multi-Cloud Connectivity
**Next Lab**: [Cross-Platform Provisioning with Crossplane](../management/crossplane-provisioning.md)
