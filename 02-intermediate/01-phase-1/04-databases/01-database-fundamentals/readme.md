# Database Fundamentals in DevOps

Databases are the foundation of stateful applications. In DevOps, the focus is on **Availability**, **Persistence**, and **Automation**.

---

## 🏗️ 1. RDBMS vs NoSQL

### Relational (SQL)
- **Structure**: Predefined schema, tables, rows, and columns.
- **Consistency**: ACID (Atomicity, Consistency, Isolation, Durability).
- **Use Cases**: Finance, order management, complex joins.
- **Tools**: PostgreSQL, MySQL, MariaDB, SQL Server.

### Non-Relational (NoSQL)
- **Structure**: Dynamic schema (JSON-like documents, key-value, graph).
- **Consistency**: BASE (Basically Available, Soft state, Eventual consistency).
- **Use Cases**: Real-time analytics, user profiles, big data.
- **Tools**: MongoDB, Redis, DynamoDB, Cassandra.

---

## 🌩️ 2. Managed vs Self-Hosted

| Feature | Self-Hosted (e.g., Docker/EC2) | Managed (e.g., AWS RDS) |
| :--- | :--- | :--- |
| **Effort** | High (you manage patching, OS) | Low (AWS manages patching, HA) |
| **Scalability** | Manual complex sharding | Click-of-a-button scaling |
| **Backups** | Custom scripts and storage | Automated daily snapshots |
| **Control** | Full root access to the DB OS | Limited access (DB level only) |

---

## 🛡️ 3. Core DevOps Concepts for DBs

### Persistence
Never run a database container without a **Volume**. If the container is deleted, the data must survive on the host or cloud disk (EBS/EFS).

### High Availability (HA)
Use **Read Replicas** for horizontal scaling of read traffic and **Multi-AZ** deployments for automatic failover.

### Security
- **Private Subnet**: Databases should *never* have a public IP.
- **Least Privilege**: Application users should only have the permissions they need (e.g., `SELECT`, `INSERT`), not `DROP TABLE`.
- **Encryption**: Enable encryption for data at rest and during transit.

---

## 🔗 Next Steps
Explore the specific database guides in the following modules to see how these theories are applied.
