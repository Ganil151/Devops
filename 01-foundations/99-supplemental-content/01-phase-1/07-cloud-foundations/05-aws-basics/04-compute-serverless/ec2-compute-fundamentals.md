# 💻 EC2 & Compute Vertical Mastery
*Version 1.0 | Under the Hood of the Elastic Compute Cloud*

---

## 🏛️ Executive Summary
Amazon EC2 provides resizable compute capacity in the cloud. This guide moves beyond launching an instance to explain the underlying hardware isolation, storage performance trade-offs, and the economics of Spot instances.

---

## 🚀 The "DevOps Why"
DevOps engineers must select the right instance type (Compute vs. Memory optimized) to balance performance and cost. Understanding the difference between **Ephemeral (Instance Store)** and **Persistent (EBS)** storage is critical to preventing data loss during automated scaling events.

---

## 🏗️ Core Architecture: Storage Performance
<img src="https://raw.githubusercontent.com/Ganil151/Devops/main/01-Beginner/01-Phase-1/07-Cloud-Foundations/REFERENCE/assets/aws-compute-storage.webp" alt="EC2 Storage Architecture" width="800">

### Instance Store vs. EBS
| Feature | Instance Store (Ephemeral) | EBS (Elastic Block Store) |
| :--- | :--- | :--- |
| **Connection** | Physically attached to the host. | Networked via AWS network. |
| **Performance** | Extremely high IOPS / Low Latency. | Scalable, but limited by network. |
| **Durability** | Data is lost on stop/terminate. | Data persists after stop/terminate. |
| **Use Case** | Caches, Temp files, Nosql DBs. | Boot volumes, Production DBs. |

---

## ⚙️ The Lifecycle of a Spot Instance
Spot instances allow you to use spare AWS capacity at up to a 90% discount.
1. **The Bid**: You request capacity. If the current Spot price is below your max bid, you get the instance.
2. **The Reclaim**: If AWS needs the capacity back, you receive a **2-minute notification** via CloudWatch events or the Instance Metadata Service.
3. **The Strategy**: SREs use **Spot Fleets** with diverse instance types (e.g., `m5.large`, `c5.large`) to ensure at least some nodes survive a reclaim event.

---

## 🛠️ CLI Quickstart: Instance Metadata
```bash
# Retrieve the internal IP address from inside the instance
curl http://169.254.169.254/latest/meta-data/local-ipv4

# Check if a Spot instance is about to be reclaimed
curl http://169.254.169.254/latest/meta-data/spot/termination-time
```

---

## ❓ Interview "Deep-Cut" Questions
1. **Explain the difference between a Nitro-based instance and a legacy Xen-based instance.**
2. **What is "EBS Optimization" and why is it important for high-performance databases?**
3. **How does the Credits system work for T3 and T2 instance families?**
4. **Compare Dedicated Instances vs. Dedicated Hosts.**
5. **How would you automate the graceful shutdown of an application upon receiving a Spot termination notice?**

---

## 🧪 Real-World Troubleshooting
**Scenario**: "I can't RDP/SSH into my newly launched EC2 instance."
- **Root Cause Check 1**: **Security Groups**. Is port 22 (SSH) or 3389 (RDP) open to your specific IP?
- **Root Cause Check 2**: **Route Table**. Is there a `0.0.0.0/0` route pointing to an Internet Gateway (IGW)?
- **Root Cause Check 3**: **Public IP**. Did you assign a Public IP or EIP, or are you trying to connect to a private address?

---
**Back to Module**: [Compute Overview](./readme.md)
