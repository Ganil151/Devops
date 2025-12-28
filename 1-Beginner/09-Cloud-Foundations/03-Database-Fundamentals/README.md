# Database Fundamentals

Welcome to the Database Fundamentals section! This directory contains foundational knowledge about databases in cloud computing, specifically focusing on AWS database services.

## Overview

Databases are essential components of modern applications, providing structured data storage, retrieval, and management capabilities. This section will guide you through the basics of database concepts and introduce you to AWS's managed database services.

## Learning Path

### 1. Database Basics
Start here to understand fundamental database concepts:
- [Database Concepts](Database%20Concepts%20and%20Fundamentals.md) - Core database principles
- [Relational vs NoSQL](01-Database-Basics/relational-vs-nosql.md) - Understanding different database types
- [Choosing Database Type](Choosing%20the%20Right%20Database%20Type.md) - Decision-making guide

### 2. RDS Basics
Learn about Amazon Relational Database Service:
- [RDS Introduction](02-RDS-Basics/rds-introduction.md) - What is RDS and why use it
- [RDS Getting Started](02-RDS-Basics/rds-getting-started.md) - Create your first RDS instance
- [RDS Backups & Snapshots](02-RDS-Basics/rds-backups-snapshots.md) - Data protection basics

### 3. DynamoDB Basics
Introduction to AWS's NoSQL database service:
- [DynamoDB Introduction](03-DynamoDB-Basics/dynamodb-introduction.md) - NoSQL with DynamoDB
- [DynamoDB Tables & Items](03-DynamoDB-Basics/dynamodb-tables-items.md) - Core concepts
- [DynamoDB Getting Started](03-DynamoDB-Basics/dynamodb-getting-started.md) - Hands-on guide

## Prerequisites

- Basic understanding of cloud computing concepts
- AWS account (free tier is sufficient)
- Familiarity with AWS Console
- Basic understanding of command line interface (optional)

## What You'll Learn

By completing this section, you will:
- ✅ Understand fundamental database concepts
- ✅ Know when to use relational vs NoSQL databases
- ✅ Be able to create and manage RDS instances
- ✅ Understand DynamoDB tables and items
- ✅ Perform basic database operations via AWS Console and CLI
- ✅ Implement basic backup and recovery strategies

## Next Steps

After mastering these fundamentals, progress to:
- **Intermediate Level**: [Database Services](../../Intermediate-Level/09-Database-Services/README.md) for advanced RDS features, DynamoDB design patterns, Aurora, and ElastiCache
- **Advanced Level**: [Database Enterprise](../../Advanced-Level/10-Database-Enterprise/README.md) for multi-region deployments, performance optimization, and enterprise security

## Additional Resources

- [AWS Database Services Overview](https://aws.amazon.com/products/databases/)
- [AWS Free Tier](https://aws.amazon.com/free/) - Practice without cost
- [AWS Documentation](https://docs.aws.amazon.com/)
- [AWS Well-Architected Framework - Database Pillar](https://aws.amazon.com/architecture/well-architected/)

---

**Ready to start?** Begin with [Database Concepts](Database%20Concepts%20and%20Fundamentals.md)!

## Database Architecture
```mermaid
graph TD
    App[Application]
    
    subgraph Relational [Relational / SQL]
        Schema[Fixed Schema]
        Table1[Table: Users]
        Table2[Table: Orders]
        Rel[Relationships]
        Table1 --- Rel --- Table2
    end
    
    subgraph NonRelational [NoSQL]
        Doc[Document Store]
        KV[Key-Value Store]
        Graph[Graph DB]
    end
    
    App -->|Structured Transasctions| Relational
    App -->|Flexible/High Scale| NonRelational
    
    classDef sql fill:#e3f2fd,stroke:#0d47a1
    classDef nosql fill:#fff3e0,stroke:#e65100
    
    class Relational sql
    class NonRelational nosql
```

## Real World Scenarios

### Scenario 1: E-Commerce Catalog Scaling
**Context:** An online retailer's product catalog has grown to millions of items with diverse attributes (some have sizes/colors, others have technical specs). The rigid SQL schema is hard to update.
**Solution:**
- **NoSQL (DynamoDB/MongoDB):** Migrate the product catalog to a Document store.
- **Flexible Schema:** New products can have arbitrary attributes without altering the table structure.
- **Read Performance:** High-speed reads for browsing products using key-value or secondary indexes.
**Benefit:** faster innovation cycles and ability to handle "Black Friday" traffic spikes due to NoSQL horizontal scaling.

### Scenario 2: Banking Transaction System
**Context:** A bank needs to record transfers between accounts. Absolute data integrity is required (money must not vanish).
**Solution:**
- **Relational (RDS/Aurora):** Use a SQL database with ACID compliance.
- **Transactions:** Wrap the "Debit Sender" and "Credit Receiver" operations in a single transaction. If one fails, both roll back.
- **Constraints:** Foreign keys ensure that transactions are only linked to valid accounts.
**Benefit:** Guarantees strong consistency and financial accuracy.

---

## Interview Questions

### Basic Level
1.  **What is the difference between SQL and NoSQL?**
    -   **SQL (Relational):** Structured data, predefined schema, valid relationships (tables, rows), scales vertically. Good for complex queries/transactions.
    -   **NoSQL (Non-Relational):** Flexible schema, various models (document, key-value), scales horizontally. Good for rapid changes, massive data, and simple query patterns.
2.  **What does ACID stand for?**
    -   **Atomicity:** All or nothing.
    -   **Consistency:** Database remains in a valid state.
    -   **Isolation:** Transactions don't interfere with each other.
    -   **Durability:** Saved data stays saved.
3.  **What is a Primary Key?**
    -   A unique identifier for a record (row) in a table. It cannot be null.

### Intermediate Level
4.  **Explain "Read Replicas" vs "Multi-AZ" in AWS RDS.**
    -   **Read Replicas:** Async copies of the DB to offload read traffic (performance).
    -   **Multi-AZ:** Sync copy in another zone for failover (High Availability). NOT for performance boosting.
5.  **What is "Sharding"?**
    -   Splitting a large dataset across multiple servers (shards) horizontally. Common in NoSQL to achieve unlimited scale. hard to do in SQL.
6.  **Comparison of DynamoDB vs RDS?**
    -   **DynamoDB:** Serverless NoSQL, single-digit ms latency, scales to zero or infinity, pays per request/capacity.
    -   **RDS:** Managed SQL (Postgres/MySQL), runs on servers (instances), pays per hour + storage.
7.  **What is a "Foreign Key"?**
    -   A field in one table that links to the Primary Key of another table, enforcing referential integrity.
8.  **Define "indexes" in a database.**
    -   Data structures (like a B-Tree) that improve the speed of data retrieval operations on a table at the cost of additional writes and storage space.

### Advanced Level
9.  **What is the CAP Theorem?**
    -   In a distributed system, you can only pick 2 out of 3: **Consistency** (every read receives the most recent write), **Availability** (every request receives a response), **Partition Tolerance** (system continues despite network message drops).
10. **Explain "Eventual Consistency".**
    -   A consistency model where, given enough time, all updates will propagate through the system and all replicas will be consistent. (CP vs AP systems).
11. **What is "Normalization" vs "Denormalization"?**
    -   **Normalization:** Organizing data to reduce redundancy (splitting tables). Good for write efficiency and integrity.
    -   **Denormalization:** Combining tables to reduce joins. Good for read performance, often used in NoSQL or Data Warehousing.
12. **How does Amazon Aurora differ from standard RDS?**
    -   Aurora separate compute from storage. The storage layer is shared across 3 AZs with 6 copies of data. It allows faster replication, auto-scaling storage, and faster failover than standard RDS.
13. **What is an "In-Memory" database (e.g., Redis/ElastiCache) used for?**
    -   Caching frequently accessed data to provide microsecond latency, relieving load on the main disk-based database (RDS/DynamoDB).

---

## Quiz: Database Fundamentals

<details>
<summary><b>1. Which database type is best for complex relationships and transactions (e.g., ERP systems)?</b></summary>
A) NoSQL<br>
B) Relational (SQL)<br>
C) Flat File<br>
D) Excel<br>
<br>
<b>Answer: B) Relational (SQL)</b>
</details>

<details>
<summary><b>2. Scaling a database by adding more power (CPU/RAM) to a single server is called:</b></summary>
A) Horizontal Scaling<br>
B) Vertical Scaling<br>
C) Diagonal Scaling<br>
D) Sharding<br>
<br>
<b>Answer: B) Vertical Scaling</b>
</details>

<details>
<summary><b>3. DynamoDB is an example of which type of database?</b></summary>
A) Relational<br>
B) Key-Value / Document (NoSQL)<br>
C) Graph<br>
D) In-Memory<br>
<br>
<b>Answer: B) Key-Value / Document (NoSQL)</b>
</details>

<details>
<summary><b>4. In RDS Multi-AZ, the standby instance is primarily used for:</b></summary>
A) Serving read traffic<br>
B) High Availability (Failover)<br>
C) Analytics<br>
D) Backups only<br>
<br>
<b>Answer: B) High Availability (Failover)</b>
</details>

<details>
<summary><b>5. Which property ensures that a transaction is "all or nothing"?</b></summary>
A) Atomicity<br>
B) Consistency<br>
C) Isolation<br>
D) Durability<br>
<br>
<b>Answer: A) Atomicity</b>
</details>

<details>
<summary><b>6. Which service provides a managed Redis or Memcached environment?</b></summary>
A) RDS<br>
B) DynamoDB<br>
C) ElastiCache<br>
D) Redshift<br>
<br>
<b>Answer: C) ElastiCache</b>
</details>

<details>
<summary><b>7. "SQL" stands for:</b></summary>
A) Strong Query Language<br>
B) Structured Query Language<br>
C) Simple Question Language<br>
D) Server Query Log<br>
<br>
<b>Answer: B) Structured Query Language</b>
</details>

<details>
<summary><b>8. A "Join" operation is a key feature of:</b></summary>
A) Key-Value Stores<br>
B) Relational Databases<br>
C) Object Storage<br>
D) DNS<br>
<br>
<b>Answer: B) Relational Databases</b>
</details>

<details>
<summary><b>9. Which AWS service is a data warehouse solution (OLAP)?</b></summary>
A) RDS<br>
B) DynamoDB<br>
C) Redshift<br>
D) Neptune<br>
<br>
<b>Answer: C) Redshift</b>
</details>

<details>
<summary><b>10. In the CAP theorem, "P" stands for:</b></summary>
A) Performance<br>
B) Partition Tolerance<br>
C) Persistence<br>
D) Privacy<br>
<br>
<b>Answer: B) Partition Tolerance</b>
</details>

<details>
<summary><b>11. What is the main benefit of "Read Replicas"?</b></summary>
A) Automatic Failover<br>
B) Reduced Write Latency<br>
C) Improved Read Performance (Offloading)<br>
D) Strong Consistency<br>
<br>
<b>Answer: C) Improved Read Performance (Offloading)</b>
</details>

<details>
<summary><b>12. MongoDB is a popular examples of a:</b></summary>
A) Relational DB<br>
B) Document Store<br>
C) Graph DB<br>
D) Time Series DB<br>
<br>
<b>Answer: B) Document Store</b>
</details>

<details>
<summary><b>13. Amazon Aurora is compatible with which two database engines?</b></summary>
A) Oracle and SQL Server<br>
B) MySQL and PostgreSQL<br>
C) MongoDB and Cassandra<br>
D) Redis and Memcached<br>
<br>
<b>Answer: B) MySQL and PostgreSQL</b>
</details>

<details>
<summary><b>14. Which statement adds data to a SQL table?</b></summary>
A) SELECT<br>
B) INSERT<br>
C) UPDATE<br>
D) DELETE<br>
<br>
<b>Answer: B) INSERT</b>
</details>

<details>
<summary><b>15. Data "Durability" refers to:</b></summary>
A) Speed of access<br>
B) Data not disappearing over time<br>
C) Uptime of the server<br>
D) Encryption strength<br>
<br>
<b>Answer: B) Data not disappearing over time</b>
</details>

<details>
<summary><b>16. Which strategy is most effective for handling un-predictable, massive traffic spikes for a simple lookup app?</b></summary>
A) RDS with auto-scaling storage<br>
B) Provisioned DynamoDB<br>
C) DynamoDB On-Demand<br>
D) EC2 with SQLite<br>
<br>
<b>Answer: C) DynamoDB On-Demand</b>
</details>

<details>
<summary><b>17. "Columns" in a NoSQL Document store are typically referred to as:</b></summary>
A) Attributes / Fields<br>
B) Tables<br>
C) Relations<br>
D) Shards<br>
<br>
<b>Answer: A) Attributes / Fields</b>
</details>

<details>
<summary><b>18. Graph databases (like Amazon Neptune) are optimized for:</b></summary>
A) Financial transactions<br>
B) Analyzing complex relationships (social networks, fraud detection)<br>
C) Video storage<br>
D) Key-Value lookups<br>
<br>
<b>Answer: B) Analyzing complex relationships (social networks, fraud detection)</b>
</details>

<details>
<summary><b>19. Database Migration Service (DMS) helps you:</b></summary>
A) Migrate databases to AWS with minimal downtime<br>
B) Design database schemas<br>
C) Write SQL queries<br>
D) Install Oracle on your laptop<br>
<br>
<b>Answer: A) Migrate databases to AWS with minimal downtime</b>
</details>

<details>
<summary><b>20. Which command modifies the structure of an existing table (e.g., adding a column)?</b></summary>
A) UPDATE TABLE<br>
B) ALTER TABLE<br>
C) CHANGE TABLE<br>
D) MODIFY TABLE<br>
<br>
<b>Answer: B) ALTER TABLE</b>
</details>

<details>
<summary><b>21. "OLTP" stands for:</b></summary>
A) Online Text Processing<br>
B) Online Transaction Processing<br>
C) Offline Table Protocol<br>
D) One Time Loading Process<br>
<br>
<b>Answer: B) Online Transaction Processing</b>
</details>
