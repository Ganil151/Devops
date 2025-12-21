# Database Services in DevOps

Data is the most valuable asset of any organization. This module focuses on how to manage, scale, and secure databases in a cloud-native environment, moving from basic containers to enterprise managed services.

---

## 1. Managed vs. Self-Hosted

Choosing how to run your database is a critical architectural decision.

| Feature | Self-Hosted (Docker/EC2) | Managed (AWS RDS/Aurora) |
| :--- | :--- | :--- |
| **Management** | You handle OS, patches, backups. | AWS handles the heavy lifting. |
| **Scaling** | Manual vertical/horizontal scaling. | Built-in Auto Scaling. |
| **Reliability** | You manage replication/HA. | Multi-AZ by default. |
| **Cost** | Lower upfront, higher operational cost. | Higher upfront, lower operational cost. |

---

## 2. Core Database Types

### Relational (SQL)
- **Use Cases**: Financial systems, structured data, complex joins.
- **Top Services**: Amazon RDS (MySQL, PostgreSQL, SQL Server), Amazon Aurora.

### NoSQL
- **Use Cases**: Real-time bidding, user profiles, big data, flexible schemas.
- **Top Services**: Amazon DynamoDB, MongoDB, Redis (ElastiCache).

---

## 3. Best Practices
1. **Persistence**: Never store database data inside a container without a **Volume** or **Persistent Volume**.
2. **Backups**: Implement automated, cross-region backups for disaster recovery.
3. **Security**: Always place your database in a **Private Subnet** and use Security Groups to limit traffic to only the application tier.
4. **Encryption**: Enable encryption-at-rest (KMS) and encryption-in-transit (SSL/TLS).

---
**Advanced Integration**: Learn how to monitor database performance in the [Observability Module](../../3-Advanced/02-Observability/README.md).