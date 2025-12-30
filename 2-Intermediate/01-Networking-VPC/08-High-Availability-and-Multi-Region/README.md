# High Availability and Multi-Region Strategies

Building a resilient network is a core pillar of the **Well-Architected Framework**.

## 🏙️ Multi-AZ Architecture (High Availability)

High Availability (HA) ensures that your application remains operational if a component or an entire data center fails.

### Core Principles
1.  **Redundancy**: Never deploy a critical resource in a single Availability Zone (AZ).
2.  **Isolation**: Faults in one AZ should not cascade to others.

### Standard VPC Pattern
-   **Region**: `us-east-1`
-   **AZ 1 (`us-east-1a`)**:
    -   Public Subnet (NAT GW, ALB Node)
    -   Private Subnet (App Server)
    -   Data Subnet (DB Primary)
-   **AZ 2 (`us-east-1b`)**:
    -   Public Subnet (NAT GW, ALB Node)
    -   Private Subnet (App Server)
    -   Data Subnet (DB Standby)

> [!TIP]
> **Autoscaling Groups** should be configured to span multiple AZs to automatically balance instances.

---

## 🌍 Multi-Region Architecture (Disaster Recovery)

Going multi-region protects against the rare event of a total regional failure (e.g., a natural disaster affecting the entire Virginia area).

### Strategies
1.  **Pilot Light**: Data is replicated to valid DR region; compute is turned off until needed. (Low Cost, Slower RTO).
2.  **Warm Standby**: A scaled-down version of the fully functional stack is always running in DR region. (Medium Cost, Faster RTO).
3.  **Active-Active**: Both regions serve traffic simultaneously. (High Cost, Zero RTO).

### Inter-Region Peering
You can peer VPCs across different regions. Traffic travels over the AWS global backbone (encrypted and optimized), not the public internet.

---

## 🌐 Global Accelerator

AWS Global Accelerator improves the availability and performance of your applications with local or global users.
-   **Static Anycast IP**: You get 2 static IPs that are announced globally.
-   **Traffic Routing**: Traffic enters the AWS network at the edge location closest to the user and rides the AWS backbone to your endpoint (ALB/EC2).
-   **Failover**: Instantly re-routes traffic to a healthy endpoint in another region if one fails (within seconds).

---

## ❓ Interview Questions

1.  **What is the difference between High Availability and Fault Tolerance?**
    *   *Answer*: HA aims to minimize downtime (e.g., 99.99% uptime). Fault Tolerance aims for zero downtime (the system continues to operate without interruption even if a component fails).
2.  **Why use Global Accelerator instead of just Route 53 Geolocation routing?**
    *   *Answer*: Route 53 relies on DNS caching, which delays failover (minutes). Global Accelerator routes at the network layer, allowing failover in seconds and avoiding caching issues.
3.  **Does Multi-AZ cost more?**
    *   *Answer*: It can. Data transfer between AZs is often billed per GB. Also, running standby resources (like RDS Multi-AZ) doubles the instance cost compared to Single-AZ.

---

## 🧠 Quiz Snippet

1.  **What is the minimum number of AZs recommended for production workloads?** `(Two)`
2.  **Which Load Balancer setup handles regional failover?** `(DNS (Route 53) or Global Accelerator)`
3.  **Does traffic between peered VPCs in different regions go over the public internet?** `(No)`
4.  **What does RTO stand for?** `(Recovery Time Objective - how long to restore service)`
5.  **What does RPO stand for?** `(Recovery Point Objective - how much data loss is acceptable)`
