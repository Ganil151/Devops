# 01. VPN Site-to-Site Fundamentals

**AWS Site-to-Site VPN** enables you to connect your on-premises network or branch office to your Amazon Virtual Private Cloud (VPC) over the **public internet**. It uses **IPsec** (Internet Protocol Security) to create encrypted tunnels.

## Core Components

A VPN connection consists of two "ends":

1.  **Customer Gateway (CGW)**: A physical device or software application on your side (on-premises) of the connection.
2.  **Virtual Private Gateway (VGW)**: The VPN concentrator on the AWS side of the connection, attached to your VPC.
3.  **VPN Connection**: The logical connection that consists of two IPsec tunnels for high availability.

```mermaid
graph LR
    subgraph Corporate_DC [On-Premises Data Center]
        CGW[Customer Gateway]
    )
    subgraph AWS_Cloud [AWS VPC]
        VGW[Virtual Private Gateway]
    )
    
    CGW <==>|Tunnel 1: IPsec| VGW
    CGW <==>|Tunnel 2: IPsec| VGW
    
    style CGW fill:#f96,stroke:#333
    style VGW fill:#69c,stroke:#333
```

## Routing Options

*   **Static Routing**: You manually enter the IP ranges (CIDRs) of your on-premises network into the AWS VPN configuration.
*   **Dynamic Routing (BGP)**: Uses the **Border Gateway Protocol (BGP)** to automatically exchange routing information between your on-premises network and AWS. **Highly recommended** for production because it supports automatic failover between tunnels.

---

## Real-Life Scenarios

### Scenario 1: "The Intermittent Tunnel"
**Problem**: A branch office reported that their connection to the cloud was dropping every hour for about 30 seconds.
**Discovery**: The IPsec "IKE Lifetime" on the on-premises firewall was set to 3600 seconds, but AWS expects a slightly different rekeying behavior.
**Solution**: Aligned the IKE Phase 1 and Phase 2 lifetimes and enabled **Dead Peer Detection (DPD)** on the customer gateway.
**Outcome**: The tunnels remained stable, rekeying seamlessly in the background.

### Scenario 2: "The Static Route Headache"
**Problem**: An organization added a new subnet to their local data center, but servers in that subnet couldn't ping the AWS VPC.
**Discovery**: They were using static routing. They forgot to manually add the new CIDR to the VPN connection's static routes in the AWS Console.
**Solution**: Switched to **Dynamic Routing (BGP)**.
**Outcome**: Now, whenever a new network is added to the local core router, BGP "advertises" it to AWS automatically. No manual console work required.

### Scenario 3: "The Single-Tunnel Risk"
**Problem**: During maintenance on the AWS side, a client's VPN went down.
**Discovery**: The client had only configured **one** of the two tunnels provided by AWS.
**Solution**: Updated the on-premises firewall to support both tunnel endpoints.
**Outcome**: During the next maintenance window, when AWS took down Tunnel 1, traffic automatically failed over to Tunnel 2. Zero downtime.

---

## ❓ Interview Questions

1. **What is a Customer Gateway (CGW)?**
    - The resource representing your physical router or firewall on the on-premises side.
2. **What is a Virtual Private Gateway (VGW)?**
    - The VPN concentrator on the AWS side that attaches to your VPC.
3. **How many tunnels are created with a single AWS Site-to-Site VPN?**
    - Two tunnels (for high availability).
4. **Does VPN traffic go over the public internet?**
    - Yes, but it is encrypted using IPsec.
5. **What is the maximum bandwidth for a single VPN tunnel?**
    - 1.25 Gbps.
6. **What is the benefit of using BGP over static routing?**
    - Automatic route propagation and failover between tunnels.
7. **What is 'DPD' (Dead Peer Detection)?**
    - A mechanism to detect if the VPN peer is alive by sending "keepalive" messages.
8. **Can you connect a VPN to a Transit Gateway?**
    - Yes, and it's recommended for multi-VPC hybrid setups.
9. **What are the two phases of an IPsec connection?**
    - IKE Phase 1 (Management Plane) and IKE Phase 2 (Data Plane).
10. **Where do you download the configuration file for your VPN?**
    - In the AWS Management Console, under the VPN Connection details (Download Configuration button).

---

## 🧠 Quiz

1. **Component for AWS side of VPN:**
    - [x] VGW
    - [ ] CGW
2. **Component for On-Prem side of VPN:**
    - [x] CGW
    - [ ] VGW
3. **Number of tunnels per VPN connection:**
    - [x] 2
    - [ ] 1
4. **Maximum bandwidth per tunnel:**
    - [x] 1.25 Gbps
    - [ ] 10 Gbps
5. **Protocol used for dynamic routing:**
    - [x] BGP
    - [ ] OSPF
6. **Is VPN traffic encrypted?**
    - [x] Yes (IPsec)
    - [ ] No
7. **Internet path for VPN:**
    - [x] Public Internet
    - [ ] Private Fiber
8. **Encryption protocol for VPN:**
    - [x] IPsec
    - [ ] TLS
9. **Component that attaches to the VPC:**
    - [x] VGW
    - [ ] IGW
10. **Does AWS provide the CGW hardware?**
    - [x] No (It's your device)
    - [ ] Yes
11. **BGP keepalive messages help with:**
    - [x] Failover detection
    - [ ] Data compression
12. **Static routing requires:**
    - [x] Manual CIDR entry
    - [ ] BGP ASNs
13. **Cost model for VPN:**
    - [x] Hourly fee + Data transfer
    - [ ] Monthly flat rate
14. **To get 2.5 Gbps bandwidth, you can use:**
    - [x] ECMP (with Transit Gateway)
    - [ ] Larger VGW
15. **Status for a healthy tunnel:**
    - [x] UP
    - [ ] ATTACHED
16. **Can you have multiple VPNs to one VGW?**
    - [x] Yes
    - [ ] No
17. **VPN over internet is best for:**
    - [x] Low-cost, fast setup
    - [ ] Low-latency Big Data
18. **Phase 1 of IKE establishes:**
    - [x] Security Association (SA)
    - [ ] Data flow
19. **If Tunnel 1 is down, traffic uses:**
    - [x] Tunnel 2
    - [ ] IGW
20. **Can a VPN connect different accounts?**
    - [x] Yes
    - [ ] No
