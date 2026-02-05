# 🗄️ Relational and NoSQL Databases

Cloud databases offer managed scalability, automated patching, and built-in high availability.

![Database Architecture Placeholder](Descriptive Diagram: A Multi-AZ RDS deployment showing a Primary instance in Zone A and a Synchronous Standby in Zone B, with Async Read Replicas across regions.)

## 🏗️ High Availability Patterns

### 1. Multi-AZ (Failover)
A synchronous standby instance is maintained in a different Availability Zone. If the primary fails, the cloud provider automatically flips the DNS record to the standby.
- **Goal**: High Availability (HA) & Disaster Recovery (DR).

### 2. Read Replicas
Asynchronous copies of your data used to offload read-heavy workloads (Reporting, Dashboards).
- **Goal**: Performance Scaling.

---

## 💎 Technical Function Comparison

| Feature | RDS (AWS) / Cloud SQL (GCP) | DynamoDB (AWS) / CosmosDB (Azure) |
| :--- | :--- | :--- |
| **Logic** | SQL (Joins, ACID) | NoSQL (Key-Value, Document) |
| **Scaling** | Vertical (Resize Instance) | Horizontal (Partitioning) |
| **Availability**| Multi-AZ Standby | Global Tables (Active-Active) |

### 💰 FinOps Tip: Idle DB Instances
Use automated scripts to stop non-production databases during weekends and non-business hours to save up to 60-70% on compute costs.

---

## 🔧 Consistency Deep-Dive
- **Strong Consistency**: Necessary for financial transactions and inventory management.
- **Eventual Consistency**: Acceptable for social media feeds or non-critical logging where a 1-second delay is tolerable.

---

## 📂 Multi-Cloud References
- **AWS**: RDS, Aurora, DynamoDB.
- **Azure**: Azure SQL, CosmosDB.
- **GCP**: Cloud SQL, Cloud Spanner, Firestore.
