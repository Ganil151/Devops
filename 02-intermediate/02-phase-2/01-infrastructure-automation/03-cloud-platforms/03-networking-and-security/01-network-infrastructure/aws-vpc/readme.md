# 🌐 AWS Virtual Private Cloud (VPC) | Intermediate Operations
> **Transitioning from "Click-and-Connect" to "Architect-Grade Isolation and Routing."**

## [00] Metadata | Module Overview
| Attribute | Detail |
| :--- | :--- |
| **Tier** | Intermediate (Phase 2) |
| **Focus** | High Availability, Security Chaining, Cost Optimization |
| **Prerequisites** | Basic Subnetting, AWS Console Basics |
| **Last Verified** | 2026-02-06 |

---

## 🗺️ Module Map
1. **[Best Practices](best-practices.md)**: SRE-grade design patterns for scalability and disaster recovery.
2. **[Networking Hacks](networking-hacks.md)**: CLI shortcuts, cost-reduction tricks, and performance tuning.
3. **[Hands-On Lab](hands-on-lab.md)**: Building a Multi-AZ, 3-Tier VPC with Endpoint Isolation.

---

## 🚀 The Intermediate "Level Up"
At the beginner level, we learn how to put an EC2 in a public subnet. At the **Intermediate Level**, we focus on:
- **Zero Trust Connectivity**: Using VPC Endpoints (PrivateLink) instead of crossing the public internet.
- **Enterprise Routing**: Managing Transit Gateways to connect 100+ VPCs without a messy peering web.
- **Security Chaining**: Referencing Security Groups by ID across different tiers for dynamic firewalling.
- **Traffic Audit**: Using VPC Flow Logs to detect "Lateral Movement" by potential attackers.

> [!IMPORTANT]
> A well-architected VPC is like a high-security bank vault. The public subnet is the foyer; the private subnet is the vault; and the database is inside a safe within that vault.

#aws #vpc #networking #sre #cloud-infrastructure
