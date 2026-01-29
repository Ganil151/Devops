# Databases in DevOps

Data is the most valuable asset of any organization. In a DevOps lifecycle, managing databases means ensuring high availability, automated backups, and seamless scalability while maintaining strict security.

## Core Concept: CAP Theorem & Consistency Models
**[REFERENCE: SQL vs NoSQL Architecture](./REFERENCE/SQL-vs-NoSQL-Architecture-Ref.md)**

Infrastructure decisions start with the data model:
- **ACID**: Atomic, Consistent, Isolated, Durable (Standard for SQL).
- **BASE**: Basically Available, Soft State, Eventual Consistency (Standard for NoSQL).
- **CAP**: You can only have 2: Consistency, Availability, Partition Tolerance.

## Enterprise Governance: Persistence & Recovery
**[REFERENCE: Database Availability & Backup](./REFERENCE/Database-Availability-Backup-Ref.md)**

Production data requires strict guardrails:
- **Multi-AZ Availability**: Synchronous replication to a standby for automated failover.
- **RPO/RTO**: Define how much data loss (RPO) and downtime (RTO) is acceptable.
- **PITR (Point-in-Time Recovery)**: Ability to restore a database to a specific second using transaction logs.
- **Testing**: A backup that hasn't been tested for restoration is not a backup.

---

## 🗺️ The Database Learning Path

Follow these modules in order to master database orchestration:

1.  **[01-Database-Fundamentals](./01-Database-Fundamentals/README.md)**: SQL vs NoSQL theory, ACID/BASE, and Managed vs Self-hosted.
2.  **[02-PostgreSQL-DevOps](./02-PostgreSQL-DevOps/README.md)**: Deep dive into the world's most advanced open-source database.
3.  **[03-MySQL-and-RDS](../../../README.md)**: Master MySQL and its cloud implementation via Amazon RDS.
4.  **[04-NoSQL-MongoDB-Redis](./04-NoSQL-MongoDB-Redis/README.md)**: Document stores and high-performance in-memory caching.
5.  **[05-Backup-and-Monitoring](./05-Backup-and-Monitoring/README.md)**: Strategies for data durability, snapshots, and performance tracking.
6.  **[06-Interview-Questions-and-Quizzes](./06-Interview-Questions-and-Quizzes/README.md)**: Test your knowledge and prepare for job screenings.
7.  **[07-Real-Life-Scenarios](./07-Real-Life-Scenarios/README.md)**: Practical troubleshootng and architecture challenges.
8.  **[📺 YouTube Lessons](./Youtube_Lessons.md)**: Curated video tutorials for visual learning.

---

## 🏗️ 1. Core DevOps Principles for DBs
- **Persistence First**: Never run a database without a mapped volume or cloud disk.
- **Failover Ready**: Always architect for Multi-AZ to ensure zero-downtime during hardware failure.
- **Security by Default**: Place databases in private subnets and encrypt sensitive data at rest and in transit.
- **Infrastructure as Code**: Manage your DB instances and schemas using tools like Terraform and Liquibase.

---

## 🛠️ Tooling Overview
- **RDMS**: PostgreSQL, MySQL, Aurora (Best for structured data).
- **NoSQL**: MongoDB, DynamoDB (Best for rapid scaling and flexible schemas).
- **Caching**: Redis, ElastiCache (Best for performance optimization).
- **Migration**: AWS DMS, pg_dump/restore.

---

## ✅ Knowledge Check
- [x] Explain the difference between ACID and BASE consistency models.
- [x] Launch a database container with persistent data volumes.
- [x] Implement a Read Replica for horizontal scaling.
- [x] Perform a point-in-time recovery (PITR) from a snapshot.
- [x] Pass the 20-Question assessment in module 06.

---

## 🔗 Next Steps
- **[Kubernetes Mastery](../07-Kubernetes/)** - Learn to run Databases in a K8s cluster.
- **[Observability Foundations](../10-Observability-Foundations/)** - Monitor your database health.

---
*Data is the truth. Protect it. Scale it. Automate it.*