# ⚡ Cloud Performance & Optimization
*Version 1.0 | Engineering for Scalability, Latency, and Cost*

---

## 📖 Overview
Performance in the cloud is not just about raw CPU power; it's about architectural efficiency. A well-optimized cloud environment scales automatically to meet demand while maintaining low latency and minimal cost.

---

## 🏗️ Technical Pillars (Scalability)

### 1. Horizontal vs Vertical Scaling
- **Vertical (Scale Up)**: Adding more CPU/RAM to a single instance. (Limited by hardware).
- **Horizontal (Scale Out)**: Adding more instances to a cluster. (Preferred for cloud-native apps).

### 2. Auto Scaling
**Definition**: Dynamically adjusting the number of compute resources based on metrics like CPU usage or Request count.
**Cloud Standard**: **ASG** (AWS), **VM Scale Sets** (Azure), **MIGs** (GCP).

---

## 🌐 Network Optimization

### Content Delivery Networks (CDN)
**Definition**: A distributed network of proxy servers that caches content closer to the users.
**Tooling**: CloudFront (AWS), Akamai, Cloudflare.
**Benefit**: Drastically reduces latency for static assets (Images, JS, CSS).

### Load Balancing
**Definition**: Distributing incoming application traffic across multiple targets.
**Types**: Application Load Balancer (Layer 7 - HTTP/S), Network Load Balancer (Layer 4 - TCP/UDP).

---

## 💰 Cost Optimization (FinOps)

- **Reserved Instances (RI)**: Committing to usage for 1-3 years in exchange for a massive discount (up to 70%).
- **Spot Instances**: Using excess provider capacity at market prices (up to 90% discount); requires apps that handle sudden termination.
- **Right-Sizing**: Consistently monitoring usage and downsizing over-provisioned resources.

---

## 🛡️ SRE Performance Checklist
- [ ] Is "Connection Pooling" enabled for database clients?
- [ ] Are logs being sampled or rate-limited to avoid excessive CloudWatch/Monitor costs?
- [ ] Is there an "Unused Resource" reaper script?
- [ ] Are global applications using **Multi-Region** replication for low-latency access?

---
**Back to Foundations**: [Cloud Computing Models →](./cloud-computing-models-ref.md)
