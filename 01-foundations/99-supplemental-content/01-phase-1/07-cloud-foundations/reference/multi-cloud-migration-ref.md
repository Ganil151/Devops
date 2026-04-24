# 🦅 Multi-Cloud & Migration Strategies
*Version 1.0 | Mastering the Transition to the Cloud*

---

## 📖 Overview
Migration to the cloud is a complex journey. For SREs, the goal is to move workloads with zero downtime and maximum reliability. Multi-cloud strategies ensure that an organization isn't tied to a single vendor's outages or pricing.

---

## 🏗️ The 6 R's of Migration

### 1. Rehost (Lift-and-Shift)
**Definition**: Moving an application to the cloud with no changes.
**Use Case**: Fast migrations or legacy apps that are too risky to touch.
**Tool**: AWS Application Migration Service.

### 2. Replatform (Lift-and-Reshape)
**Definition**: Making minor optimizations to run the app on a managed service (e.g., moving a DB from an EC2 instance to RDS).

### 3. Refactor / Re-architect
**Definition**: Re-imagining how the app is architected, usually using cloud-native features like microservices or serverless.

### 4. Repurchase (Drop-and-Shop)
**Definition**: Moving to a different product, typically a SaaS version of the existing app (e.g., self-hosted email to O365).

### 5. Retire
**Definition**: Identifying and turning off applications that are no longer useful.

### 6. Retain (Revisit)
**Definition**: Keeping certain applications on-prem for high-compliance or latency reasons.

---

## 🌐 Multi-Cloud Principles
- **Agility**: Avoid proprietary APIs (use Terraform, Kubernetes).
- **Resilience**: Spread critical services across AWS and Azure to survive a region-wide provider failure.
- **Portability**: Data is the "gravity" of the cloud. Ensure data can be synced between providers.

---

## 💡 SRE Pro-Tips
- **The "Migration Wave"**: Start with low-critically internal tools to test your migration pipeline before touching production.
- **Network Latency**: In multi-cloud setups, the latency between AWS and GCP can be high. Keep "Chunky" API calls within the same provider.
- **Direct Connect / ExpressRoute**: Use private fiber connections for massive data migrations to avoid high data-egress costs over the public internet.

---
**Next Step**: [Serverless Architecture →](./serverless-architecture-ref.md)
