# Advanced Cloud Networking Challenges 🌍

Master global-scale connectivity, BGP routing, and Hybrid Cloud architectures.

---

## 🏆 Challenge 01: Global VPC Transit
**Objective**: Build a high-availability global network hub using AWS Transit Gateway.

1.  **Scenario**: Your company has VPCs in **US-East-1**, **EU-West-1**, and **AP-Southeast-1**.
2.  **Task**: Design a "Hub-and-Spoke" architecture using Transit Gateway Peering.
3.  **Constraint**: Traffic from EU-West-1 to AP-Southeast-1 must pass through the US-East-1 Hub for security inspection.
4.  **Action**: Draft the Transit Gateway Route Tables for all three regions.
5.  **Question**: How does TGW Peering handle overlapping CIDRs? (Research: NAT within TGW).

---

## 🏆 Challenge 02: BGP Routing over VPN
**Objective**: Implement dynamic routing between On-Prem and Cloud.

1.  **Requirement**: A Site-to-Site VPN with **Dynamic Routing (BGP)**.
2.  **Task**: Define the Autonomous System Number (ASN) strategy for a tiered network.
3.  **Lab**: Write the BGP configuration snippet for a Cisco CSR1000v router to pair with AWS Customer Gateway.
4.  **Discovery**: What is the difference between "Static" and "Dynamic" VPN tunnels in terms of path failover?

---

## 🏆 Challenge 03: PrivateLink for B2B SaaS
**Objective**: Expose microservices to customers securely.

1.  **Scenario**: You are a SaaS provider. You want to give Customer A access to your API (internal NLB) without them leaving the cloud backbone.
2.  **Task**: Create an **Endpoint Service** in your provider VPC.
3.  **Requirement**: 
    *   Enable "Acceptance Required."
    *   Whitelist Customer A's AWS Account ID.
4.  **Verification**: How does the customer "Consume" your service? (Research: Interface Endpoints).

---

## 📁 Solutions
BGP configurations and PrivateLink Terraform modules are in the `Boilerplates/` directory.
