# 📑 AWS VPC | SRE Best Practices & Design Patterns
> **"Design for failover, build for isolation, and optimize for cost."**

## [01] IPAM & CIDR Planning | The Foundation
**Keywords:** #ipam #cidr #planning #scalability

| Principle | Action | Why? |
| :--- | :--- | :--- |
| **Avoid Overlap** | Never use `10.0.0.0/16` for every VPC. | Prevents VPC Peering and VPN connectivity issues later. |
| **Sizing for Growth** | Allocate `/20` or `/19` blocks even if small. | Subnets are easy to add; VPC CIDRs are hard to modify. |
| **Reserved Ranges** | Keep a "Buffer" CIDR range for future TGW or hybrid connections. | Avoids re-architecting your network during M&A or growth. |

---

## [02] Subnet Strategy | The Tiers
**Keywords:** #subnets #security #isolation

### 🏗️ The 3-Tier Pattern (Standard)
1. **Public Subnet**: Load Balancers, NAT Gateways, Bastion Hosts.
2. **Private App Subnet**: API Gateways, Microservices, Worker Nodes.
3. **Private Data Subnet**: RDS, ElastiCache, Redshift (No NAT route!).

> [!CAUTION] 
> Never place a Database in a subnet that has a route to a NAT Gateway. Databases should only be reachable from the App tier Security Group.

---

## [03] Connectivity & Routing | Transit vs Peering
**Keywords:** #routing #transit-gateway #peering

| Feature | VPC Peering | Transit Gateway (TGW) |
| :--- | :--- | :--- |
| **Scale** | 1-to-1 relationships. | Hub-and-Spoke (Centralized). |
| **Complexity** | Becomes a "Spaghetti" web at 5+ VPCs. | Single management point for all routes. |
| **Cost** | Free (only data transfer costs). | Hourly charge + data processing fee ($$$). |
| **Best Use** | Low-latency, small scale. | Global enterprise connectivity. |

---

## [04] Security Best Practices | The Shield
**Keywords:** #security #firewall #nacl #security-group

### 🧪 Security Group source Chaining
Instead of allowing `10.0.2.0/24` in your DB Security Group, use:
```bash
# Inbound Rule on DB-SG:
Protocol: TCP | Port: 5432 | Source: sg-app-tier-id
```
**Why?** If you auto-scale your App Tier, the DB automatically trusts the new instances regardless of their IP.

### ⛔ NACL vs SG Logic
- **Security Groups**: Default "Deny All". Use for day-to-day app isolation.
- **NACLs**: Use as "Subnet-Wide Guardrails" (e.g., blocking an entire region or specific malicious IP).

---

## [05] VPC Endpoints | The Private Freeway
**Keywords:** #privatelink #vpc-endpoint #cost-optimization

| Type | Cost | Use Case |
| :--- | :--- | :--- |
| **Gateway Endpoint** | FREE | S3 and DynamoDB only. |
| **Interface Endpoint** | Paid ($/hour) | Everything else (SNS, SQS, EC2 API). |

> **SRE Pro-Tip**: Always create a **Gateway Endpoint for S3** immediately. It saves thousands of dollars in NAT Gateway data processing fees.

---
*Last Verified: 2026-02-06 - Optimized for Intermediate SRE Workflows*
