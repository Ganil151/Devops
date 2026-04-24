# SQL vs NoSQL: Architectural Reference

**Doc Version:** 1.0.0
**Role:** Database Architect
**Scope:** Consistency Models, Scaling, and Use Cases

---

## 1. ACID vs. BASE

The fundamental divide in database architecture is how they handle consistency and availability.

### ACID (Relational / SQL)
*Used by: PostgreSQL, MySQL, Oracle*
- **Atomicity**: Transactions are all-or-nothing.
- **Consistency**: Data follows all defined rules (constraints, triggers).
- **Isolation**: Concurrent transactions don't interfere.
- **Durability**: Once committed, data stays committed even after power loss.
- **Focus**: **Strong Consistency**.

### BASE (Non-Relational / NoSQL)
*Used by: MongoDB, Cassandra, DynamoDB*
- **Basically Available**: The system guarantees availability.
- **Soft State**: The state may change over time without input (due to eventual consistency).
- **Eventual Consistency**: Given time, all nodes will see the same data.
- **Focus**: **High Availability & Partition Tolerance**.

---

## 2. Scaling Models

| Factor | SQL (Vertical) | NoSQL (Horizontal) |
| :--- | :--- | :--- |
| **Strategy** | Add more CPU/RAM/Disk to a single server. | Add more servers (nodes) to a cluster. |
| **Complexity** | Simple, but has a "ceiling" (max server size). | Complex (requires sharding/partitioning). |
| **Data Relationship** | Joins are efficient on a single node. | Joins are expensive/impossible across nodes. |

---

## 3. The CAP Theorem

You can only have 2 out of 3 in a distributed system:
1.  **Consistency**: Every read receives the most recent write.
2.  **Availability**: Every request receives a response (success/failure).
3.  **Partition Tolerance**: System continues to operate despite network failures.

> **DevOps Note**: Most cloud databases are **AP** (Available and Partition Tolerant) with "Sync" options to achieve **CP**.

---

## 4. When to Choose What?

### Choose SQL (Relational) if:
- You have highly structured data with complex relationships.
- You require financial-grade consistency (Double-entry bookkeeping).
- Your workload fits on a single large server or can be handled by Read Replicas.

### Choose NoSQL if:
- You have unstructured or rapidly changing data (JSON docs).
- You need to scale to millions of users globally.
- You prioritize availability over immediate consistency (e.g., social media feeds).

---

## 5. Visualizing Data Models

```mermaid
graph TD
    subgraph "SQL: Structured"
    Table1[User Table] -- Foreign Key --> Table2[Orders Table]
    end
    
    subgraph "NoSQL: Document"
    Doc1[User Document {ID, Name, Orders: [...]}]
    end
```

> **Enterprise Pattern**: Use **Polyglot Persistence**. Use PostgreSQL for your source of truth (User/Billing) and Redis for your cache, and MongoDB for your high-velocity logs.
