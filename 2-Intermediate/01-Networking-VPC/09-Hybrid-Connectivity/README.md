# Hybrid Connectivity

Connecting your on-premises data center to your cloud VPC allows for hybrid cloud architectures, enabling you to leverage the cloud's scalability while maintaining legacy systems on-prem.

## 🌉 AWS Site-to-Site VPN

A secure connection over the **public internet** using IPsec tunnels.

### Components
1.  **Virtual Private Gateway (VGW)**: Attached to your VPC (AWS side).
2.  **Customer Gateway (CGW)**: Represents your physical router/firewall (On-Prem side).
3.  **VPN Connection**: The IPsec tunnel linking the VGW and CGW.

### Characteristics
-   **Setup Time**: Minutes.
-   **Cost**: Low hourly fee per connection.
-   **Reliability**: Dependent on internet stability.
-   **Bandwidth**: Maximum 1.25 Gbps per tunnel.

---

## 🔌 AWS Direct Connect (DX)

A dedicated physical fiber connection between your network and AWS. It bypasses the public internet entirely.

### Characteristics
-   **Setup Time**: Weeks to Months (Physical installation required).
-   **Cost**: High (Port hours + Data transfer).
-   **Reliability**: Extremely high (SLA backed).
-   **Bandwidth**: 1 Gbps, 10 Gbps, or 100 Gbps dedicated.
-   **Security**: Private connection (not encrypted by default, but stays off internet).

### Connection Types
1.  **Dedicated Connection**: Physical port owned by you.
2.  **Hosted Connection**: Provided by an AWS Partner (APN) who shares their link.

---

## 📊 Comparison: VPN vs. Direct Connect

| Feature | Site-to-Site VPN | Direct Connect |
| :--- | :--- | :--- |
| **Network Path** | Public Internet | Dedicated Private Fiber |
| **Security** | Encrypted (IPsec) | Private (Unencrypted by default) |
| **Throughput** | Up to 1.25 Gbps | Up to 100 Gbps |
| **Latency** | Variable (Internet jitters) | Consistent, Ultra-low |
| **Cost** | Low ($) | High ($$$) |
| **Use Case** | Backup, Test/Dev, Small Offices | Big Data, Hybrid Workloads, Compliance |

> [!TIP]
> **VPN over Direct Connect**: For maximum security, you can establish an IPsec VPN tunnel *over* your Direct Connect link to get both privacy (DX) and encryption (VPN).

---

## ❓ Interview Questions

1.  **Can I access S3 buckets over Direct Connect?**
    *   *Answer*: Yes, by using a **Public VIF** (Virtual Interface). Private VIFs are for accessing private IPs in your VPC.
2.  **What is the maximum speed of a Site-to-Site VPN?**
    *   *Answer*: 1.25 Gbps per tunnel. You can use ECMP (Equal Cost Multi-Path) with Transit Gateway to aggregate multiple tunnels for higher bandwidth.
3.  **Does Direct Connect provide encryption by default?**
    *   *Answer*: No. It is a private line, but traffic is not encrypted at Layer 3. You must add MACsec (Layer 2) or use a VPN (Layer 3) for encryption.

---

## 🧠 Quiz Snippet

1.  **Which component represents your on-premises firewall in AWS?** `(Customer Gateway - CGW)`
2.  **Which solution provides a consistent network experience?** `(Direct Connect)`
3.  **How long does it take to provision a new Direct Connect?** `(Weeks to Months)`
4.  **Can you have a backup VPN for your Direct Connect?** `(Yes, highly recommended for failover)`
5.  **What does VGW stand for?** `(Virtual Private Gateway)`
