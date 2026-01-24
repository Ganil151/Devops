# Advanced Networking Challenges 🏢

Master complex connectivity patterns like VPC Peering, Transit Gateways, and Direct Connect.

---

## 🏆 Challenge 01: Peer-to-Peer Architecture
**Objective**: Connect two isolated VPCs to allow inter-service communication.

1.  **Requirement**: Design a solution to connect `VPC-App` (10.1.0.0/16) and `VPC-DB` (10.2.0.0/16).
2.  **Task**: Document the three steps required:
    *   **The Request**: Creating the Peering Connection.
    *   **The Acceptance**: Accepting the handshake.
    *   **The Routing**: Updating both VPC Route Tables to point to the `pcx-` ID.
3.  **Critical Question**: Can VPC-A talk to VPC-C through VPC-B automatically? (Research: Transitive Peering).

---

## 🏆 Challenge 02: Transit Gateway Centralization
**Objective**: Simplify a "Spoke-and-Hub" network.

1.  **Scenario**: You have 15 VPCs that all need to talk to a shared "Security VPC."
2.  **Task**: Explain why a Transit Gateway (TGW) is better than 15 individual Peering connections.
3.  **Lab**: Draft a TGW Route Table entry that acts as a "Blackhole" for sensitive traffic between Subnet A and Subnet B.

---

## 🏆 Challenge 03: Hybrid Cloud Connectivity
**Objective**: Bridge the gap between On-Premise and AWS/Azure.

1.  **Requirement**: Compare **Site-to-Site VPN** and **Direct Connect (DX)**.
2.  **Task**: Create a decision matrix based on:
    *   Cost
    *   Setup Time
    *   Reliability (Public Internet vs Private Fiber)
3.  **Goal**: Recommend the best solution for a bank requiring 10Gbps consistent throughput.

---

## 📁 Solutions
Advanced routing templates are in the `Boilerplates/` directory.
