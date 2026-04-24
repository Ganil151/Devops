# Database Services - Intermediate

Modern applications require reliable data storage. This module covers managed database services including relational (RDS) and NoSQL (DynamoDB).

---

## 1. Managed Databases vs. Self-hosted

Why use AWS managed databases?
- **Automation**: Automated backups, patching, and minor version upgrades.
- **High Availability**: Multi-AZ deployments with one click.
- **Scalability**: Read Replicas (Relational) and On-demand scaling (NoSQL).

---

## 2. Service Comparison

### Relational (RDS / Aurora)
- **Best For**: Complex queries, normalized data, ACID compliance.
- **Services**: MySQL, PostgreSQL, SQL Server, Oracle.
- **Aurora**: AWS-native database that is 5x faster than standard MySQL.

### NoSQL (DynamoDB)
- **Best For**: High throughput, millisecond latency at scale, simple key-value queries.
- **Service**: Amazon DynamoDB (Serverless).

---

## 3. Learning Path & Sub-Modules

### 🐘 [RDS Advanced Overviews](readme.md)
Deep dive into Read Replicas, Multi-AZ failover, and performance tuning.

### ⚡ [DynamoDB Operations](readme.md)
Mastering partitions, indexes (GSI/LSI), and DAX for caching.

### 🏎️ [In-Memory Caching](readme.md)
Using Redis and Memcached with ElastiCache to speed up your apps.

---

## 4. Best Practices
- **Snapshot Often**: Before major updates, manual snapshots are your safety net.
- **Disable Public Access**: Database subnets should *never* have an Internet Gateway route.
- **Monitor IOPS**: Ensure your database has enough "Provisioned IOPS" to handle disk heavy workloads.

---
**Security**: See [Database Security](readme.md) for enterprise encryption and IAM integration.
