# Relational vs NoSQL Databases

## Overview

Choosing between relational (SQL) and NoSQL databases is one of the most important architectural decisions you'll make. This guide helps you understand the differences, trade-offs, and when to use each type.

## Quick Comparison

| Aspect | Relational (SQL) | NoSQL |
|--------|------------------|-------|
| **Data Structure** | Tables with rows/columns | Flexible (key-value, document, column, graph) |
| **Schema** | Fixed, predefined | Flexible, dynamic |
| **Scaling** | Vertical (scale-up) | Horizontal (scale-out) |
| **ACID** | Strong ACID guarantees | Often eventual consistency |
| **Joins** | Complex joins supported | Limited or no joins |
| **Use Cases** | Financial, CRM, ERP | Real-time web, IoT, gaming |
| **Query Language** | SQL (standardized) | Varied by database |

## Relational Databases (SQL)

### Structure
Data is organized in tables with predefined schemas

```sql
-- Predefined schema
CREATE TABLE customers (
  customer_id INT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(255) UNIQUE,
  created_at TIMESTAMP
);

CREATE TABLE orders (
  order_id INT PRIMARY KEY,
  customer_id INT,
  total DECIMAL(10,2),
  status VARCHAR(20),
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
```

### Strengths
✅ **Data Integrity**: Strong constraints and relationships  
✅ **ACID Transactions**: Guaranteed consistency  
✅ **Complex Queries**: JOINs, subqueries, aggregations  
✅ **Mature Ecosystem**: Decades of tools and expertise  
✅ **Standardized Language**: SQL works across databases  

### Weaknesses
❌ **Rigid Schema**: Changes require migrations  
❌ **Vertical Scaling**: Limited horizontal scalability  
❌ **Performance**: Can slow with complex joins at scale  
❌ **Fixed Structure**: Hard to store varied data types  

### AWS Services
- **Amazon RDS**: MySQL, PostgreSQL, MariaDB, Oracle, SQL Server
- **Amazon Aurora**: High-performance MySQL/PostgreSQL compatible

## NoSQL Databases

### Types and Structures

#### 1. Key-Value (DynamoDB, Redis)
Simple key-value pairs, extremely fast lookups

```python
{
  "session:abc123": {
    "userId": "user_456",
    "loginTime": "2024-01-15T10:30:00Z",
    "preferences": {"theme": "dark"}
  }
}
```

**Best for**: Caching, session storage, user preferences

#### 2. Document (DocumentDB, MongoDB)
Nested JSON-like documents

```json
{
  "_id": "order_12345",
  "customer": {
    "name": "Alice",
    "email": "alice@example.com"
  },
  "items": [
    {"product": "Laptop", "price": 999.99, "qty": 1},
    {"product": "Mouse", "price": 29.99, "qty": 2}
  ],
  "total": 1059.97,
  "status": "shipped"
}
```

**Best for**: Content management, catalogs, user profiles

#### 3. Column-Family (Cassandra)
Wide-column storage

```
UserActivity Table
RowKey: user_123
├─ profile:name = "Alice"
├─ profile:email = "alice@example.com"
├─ activity:2024-01-15 = "logged_in"
├─ activity:2024-01-16 = "purchased_item"
└─ activity:2024-01-17 = "viewed_product"
```

**Best for**: Time-series data, IoT sensors, analytics

#### 4. Graph (Neptune)
Nodes and relationships

```
(Alice)-[:FOLLOWS]->(Bob)
(Alice)-[:LIKES]->(Product_A)
(Bob)-[:PURCHASED]->(Product_A)
(Product_A)-[:SOLD_BY]->(Store_X)
```

**Best for**: Social networks, recommendations, fraud detection

### Strengths
✅ **Flexible Schema**: Adapt to changing requirements  
✅ **Horizontal Scaling**: Add more servers easily  
✅ **High Performance**: Optimized for specific access patterns  
✅ **Varied Data**: Store different structures together  
✅ **Developer Friendly**: JSON-like formats  

### Weaknesses
❌ **Limited Transactions**: Often eventual consistency  
❌ **No Joins**: Must denormalize or make multiple queries  
❌ **No Standard Query Language**: Each database differs  
❌ **Complexity**: Requires careful data modeling  

### AWS Services
- **Amazon DynamoDB**: Serverless key-value/document database
- **Amazon DocumentDB**: MongoDB-compatible
- **Amazon Neptune**: Graph database
- **Amazon ElastiCache**: In-memory data store

## Detailed Comparison

### Data Relationships

**Relational**: Uses foreign keys and JOINs
```sql
-- Get customer orders with JOIN
SELECT c.name, o.total, o.status
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE c.email = 'alice@example.com';
```

**NoSQL**: Embeds or denormalizes data
```json
{
  "customerId": "alice_123",
  "name": "Alice",
  "email": "alice@example.com",
  "orders": [
    {"orderId": "order_1", "total": 99.99, "status": "shipped"},
    {"orderId": "order_2", "total": 149.99, "status": "delivered"}
  ]
}
```

### Schema Changes

**Relational**: Requires migration
```sql
-- Adding a column requires ALTER TABLE
ALTER TABLE customers ADD COLUMN phone VARCHAR(20);
-- Affects all existing rows
```

**NoSQL**: Flexible updates
```json
// Old document
{"name": "Alice", "email": "alice@example.com"}

// New document with phone (no migration needed)
{"name": "Bob", "email": "bob@example.com", "phone": "+1234567890"}
```

### Scaling Approaches

**Relational (Vertical Scaling)**:
```
Single Large Server
┌─────────────────────┐
│  CPU: 64 cores      │
│  RAM: 512 GB        │  ← Upgrade hardware
│  Storage: 10 TB SSD │
└─────────────────────┘
Expensive, has limits
```

**NoSQL (Horizontal Scaling)**:
```
Multiple Smaller Servers
┌──────────┐  ┌──────────┐  ┌──────────┐
│ 8 cores  │  │ 8 cores  │  │ 8 cores  │
│ 32 GB    │  │ 32 GB    │  │ 32 GB    │  ← Add more nodes
│ 1 TB SSD │  │ 1 TB SSD │  │ 1 TB SSD │
└──────────┘  └──────────┘  └──────────┘
Cost-effective, unlimited
```

## Decision Framework

### Use Relational When:

✅ **Data is highly structured** with clear relationships
```
Example: E-commerce with customers, orders, products, inventory
```

✅ **ACID transactions are critical**
```
Example: Banking, financial systems, payments
```

✅ **Complex queries and reports needed**
```
Example: Business intelligence, analytics dashboards
```

✅ **Data integrity is paramount**
```
Example: Healthcare records, legal documents
```

✅ **Schema is stable and well-defined**
```
Example: Enterprise applications, CRM systems
```

### Use NoSQL When:

✅ **High scalability required**
```
Example: Social media platforms, gaming leaderboards
```

✅ **Flexible/evolving data models**
```
Example: Content management, product catalogs
```

✅ **High-speed read/write operations**
```
Example: Real-time analytics, IoT data ingestion
```

✅ **Unstructured or semi-structured data**
```
Example: Logs, sensor data, user-generated content
```

✅ **Geographic distribution needed**
```
Example: Global applications, multi-region services
```

## Real-World Examples

### E-Commerce Platform

**Relational for** (RDS/Aurora):
- Order processing and payment transactions
- Inventory management
- Customer account data
- Order history and invoicing

**NoSQL for** (DynamoDB):
- Product catalog (varying attributes)
- Shopping cart (session data)
- User reviews and ratings
- Real-time inventory lookups

### Social Media Application

**Relational for** (RDS):
- User authentication
- Billing and subscriptions
- Content moderation workflows

**NoSQL for** (DynamoDB + DocumentDB):
- User profiles and posts
- Activity feeds
- Notifications
- Messaging and comments

**Graph Database** (Neptune):
- Friend connections
- Recommendations
- Influencer analysis

## Hybrid Approaches

Modern applications often use **both**:

```
┌─────────────────────────────────────────┐
│           Application Layer             │
└──────────┬────────────────────┬─────────┘
           │                    │
    ┌──────▼──────┐      ┌─────▼─────┐
    │ RDS/Aurora  │      │ DynamoDB  │
    ├─────────────┤      ├───────────┤
    │ Orders      │      │ Catalog   │
    │ Inventory   │      │ Sessions  │
    │ Payments    │      │ Cache     │
    └─────────────┘      └───────────┘
```

**Example Architecture**:
1. **RDS**: Critical transactional data (orders, payments)
2. **DynamoDB**: High-throughput reads (product catalog)
3. **ElastiCache**: Caching layer (session data, frequent queries)
4. **Neptune**: Recommendation engine (user relationships)

## Migration Considerations

### Migrating from Relational to NoSQL

**Challenges**:
- Redesigning data model (denormalization)
- Rewriting queries
- Handling eventual consistency
- Testing thoroughly

**When to Consider**:
- Scaling limits reached
- Need global distribution
- Read-heavy workload
- Schema changes too frequent

### Migrating from NoSQL to Relational

**Challenges**:
- Defining rigid schema
- Normalizing data
- Complex data transformations

**When to Consider**:
- Need strong consistency
- Complex reporting requirements
- Regulatory compliance
- Transaction support needed

## Cost Comparison

### Relational (RDS)
```
Pricing Factors:
- Instance type (compute)
- Storage (provisioned)
- I/O operations
- Multi-AZ deployment
- Backup storage

Example: db.t3.medium with 100GB
~$70-100/month base cost
```

### NoSQL (DynamoDB)
```
Pricing Factors:
- Read/write capacity units OR
- On-demand per request
- Storage
- Optional features (streams, backups)

Example: On-demand with 1M reads/writes
~$0.25 per million requests
Pay only for what you use
```

## Key Takeaways

| Decision Factor | Choose Relational | Choose NoSQL |
|----------------|-------------------|--------------|
| **Data Structure** | Structured, relational | Flexible, varied |
| **Consistency** | Strong ACID | Eventual consistency OK |
| **Scaling** | Vertical, bounded | Horizontal, unlimited |
| **Transactions** | Critical | Not critical |
| **Queries** | Complex JOINs | Simple key-lookups |
| **Speed of Change** | Stable schema | Rapid iteration |

## Next Steps

- **[Choosing Database Type](Choosing%20the%20Right%20Database%20Type.md)** - Practical decision guide
- **[RDS Introduction](../02-RDS-Basics/rds-introduction.md)** - Start with relational databases
- **[DynamoDB Introduction](../03-DynamoDB-Basics/dynamodb-introduction.md)** - Explore NoSQL

---


---

## Part 2: Real-World Scenarios

### Scenario 1: The "Too Many Joins" Problem
**Situation:** A legacy CRM application built on MySQL takes 15 seconds to load a user's dashboard. It joins 12 different tables (User, Orders, Tickets, Emails, Addresses, Company, etc.) to fetch the profile.
**Analysis:** Relational databases excel at normalization, but heavy join operations on large tables killed performance. The schema was too rigid for the agile "customer 360" view they needed.
**Solution:** They adopted a **hybrid approach**. They kept the core transaction data in MySQL but created a "Read Model" in a **Document Store (MongoDB/DocumentDB)**. This NoSQL database stores a single, pre-joined JSON document for each user. Dashboard load time dropped to 200ms because it's now just a single key-lookup.

### Scenario 2: The Black Friday Spike
**Situation:** An e-commerce site uses a single large SQL instance. On Black Friday, traffic spiked 50x. The database CPU hit 100%, and they couldn't scale up (vertical scaling) fast enough because the biggest server was already provisioned.
**Analysis:** Relational databases are harder to scale horizontally (sharding is complex). The "Session" and "Cart" tables were taking the most heat (millions of small, temporary writes).
**Solution:** They moved Session and Cart data to a **Key-Value Store (DynamoDB)**. This service scales horizontally and handles the massive write throughput effortlessly. Order processing remained in SQL for ACID guarantees.

### Scenario 3: The IoT Flood
**Situation:** A logistics company installed sensors on 10,000 trucks, sending GPS and temperature data every 5 seconds. Their SQL database grew by 200GB a day, and query performance for historical analysis crashed.
**Analysis:** SQL rows have overhead. Inserting millions of rows per hour caused locking issues, and deleting old data (retention policy) was slow and fragmented the index.
**Solution:** They migrated sensor logs to a **Column-Family Store / Time-Series Database (Amazon Timestream / Cassandra)**. These are optimized for write-heavy append-only workloads and efficient time-range queries.

---

## Part 3: Interview Questions

### Basic Level
1.  **What is the main difference in scaling between SQL and NoSQL?**
    -   SQL databases typically scale **Vertically** (bigger server: more RAM, CPU), which has a hard ceiling. NoSQL databases scale **Horizontally** (adding more servers/nodes), theoretically allowing unlimited scale.
2.  **What does "Schema-less" mean in NoSQL?**
    -   It means the database doesn't enforce a rigid structure. You can insert a document with fields A and B, and another with fields A, B, and C into the same collection without altering the table structure.
3.  **Give an example of when you would definitely choose a Relational Database.**
    -   A banking ledger. You need strict ACID compliance to ensure money isn't created or destroyed during transfers, and the data structure (accounts, transactions) is stable.

### Intermediate Level
4.  **Explain "Sharding" in the context of NoSQL.**
    -   Sharding is a method of horizontal partitioning. Data is distributed across multiple machines based on a "Shard Key" (e.g., UserID). This allows the database to exceed the storage and throughput limits of a single server.
5.  **Why are JOINs generally avoided or expensive in distributed NoSQL systems?**
    -   In a distributed system, data for "Table A" and "Table B" might live on different physical servers. Joining them requires moving large amounts of data over the network ("shuffling"), which is slow and inefficient compared to a local join on a single SQL server.

---

## Part 4: Knowledge Quiz

<details>
<summary><b>1. Relational databases store data in:</b></summary>
A) Documents<br>
B) Graphs<br>
C) Tables with Rows and Columns<br>
D) Key-Value pairs<br>
<br>
<b>Answer: C) Tables with Rows and Columns</b>
</details>

<details>
<summary><b>2. Which is a characteristic of most NoSQL databases?</b></summary>
A) Rigid Schema<br>
B) Vertical Scaling predominantly<br>
C) Horizontal Scaling<br>
D) Complex JOIN support<br>
<br>
<b>Answer: C) Horizontal Scaling</b>
</details>

<details>
<summary><b>3. DynamoDB is best described as:</b></summary>
A) Relational<br>
B) Key-Value / Document<br>
C) Graph<br>
D) In-Memory only<br>
<br>
<b>Answer: B) Key-Value / Document</b>
</details>

<details>
<summary><b>4. SQL stands for:</b></summary>
A) Standard Query Logic<br>
B) Structured Query Language<br>
C) Simple Question Language<br>
D) Strong Query List<br>
<br>
<b>Answer: B) Structured Query Language</b>
</details>

<details>
<summary><b>5. Which database type is optimized for deep relationship traversal (e.g., social graphs)?</b></summary>
A) Document<br>
B) Column-Family<br>
C) Graph<br>
D) Relational<br>
<br>
<b>Answer: C) Graph</b>
</details>

<details>
<summary><b>6. "Vertical Scaling" involves:</b></summary>
A) Adding more servers to the cluster<br>
B) Increasing the power (CPU/RAM) of a single server<br>
C) Deleting old data<br>
D) Moving to the cloud<br>
<br>
<b>Answer: B) Increasing the power (CPU/RAM) of a single server</b>
</details>

<details>
<summary><b>7. ACID guarantees are strongest in:</b></summary>
A) Typical NoSQL systems<br>
B) Relational (SQL) systems<br>
C) File systems<br>
D) Caches<br>
<br>
<b>Answer: B) Relational (SQL) systems</b>
</details>

<details>
<summary><b>8. A JSON object fits best into which type of database?</b></summary>
A) Document Store<br>
B) Relational Store<br>
C) Graph Store<br>
D) Column Store<br>
<br>
<b>Answer: A) Document Store</b>
</details>

<details>
<summary><b>9. If you need to store Session Data with extremely fast lookup, use:</b></summary>
A) Redshift<br>
B) MySQL<br>
C) Redis / DynamoDB (Key-Value)<br>
D) Neptune<br>
<br>
<b>Answer: C) Redis / DynamoDB (Key-Value)</b>
</details>

<details>
<summary><b>10. Changing the schema in a Relational Database usually requires:</b></summary>
A) Nothing, it's automatic<br>
B) A migration (ALTER TABLE)<br>
C) Deleting the database<br>
D) A restart only<br>
<br>
<b>Answer: B) A migration (ALTER TABLE)</b>
</details>

<details>
<summary><b>11. Which is easier to scale to Terabytes/Petabytes of active data?</b></summary>
A) MySQL<br>
B) PostgreSQL<br>
C) Cassandra/DynamoDB (NoSQL)<br>
D) SQLite<br>
<br>
<b>Answer: C) Cassandra/DynamoDB (NoSQL)</b>
</details>

<details>
<summary><b>12. "Denormalization" means:</b></summary>
A) Cleaning data<br>
B) Duplicating data to optimize read performance (common in NoSQL)<br>
C) Compressing data<br>
D) Encrypting data<br>
<br>
<b>Answer: B) Duplicating data to optimize read performance</b>
</details>

<details>
<summary><b>13. Amazon RDS manages which type of database?</b></summary>
A) NoSQL<br>
B) Graph<br>
C) Relational<br>
D) Ledger<br>
<br>
<b>Answer: C) Relational</b>
</details>

<details>
<summary><b>14. Which is a downside of NoSQL?</b></summary>
A) Slow performance<br>
B) Rigid schema<br>
C) Often lacks standardized query language and complex joins<br>
D) Cannot scale<br>
<br>
<b>Answer: C) Often lacks standardized query language and complex joins</b>
</details>

<details>
<summary><b>15. Why might a startup choose NoSQL initially?</b></summary>
A) Better ACID transactions<br>
B) Rapid development with flexible data models<br>
C) It has been around longer<br>
D) It helps with SQL training<br>
<br>
<b>Answer: B) Rapid development with flexible data models</b>
</details>

<details>
<summary><b>16. Which AWS service is equivalent to MongoDB?</b></summary>
A) RDS<br>
B) DocumentDB<br>
C) ElastiCache<br>
D) Redshift<br>
<br>
<b>Answer: B) DocumentDB</b>
</details>

<details>
<summary><b>17. In a Document store, related data is often:</b></summary>
A) Joined from another table<br>
B) Nested within the same document<br>
C) Stored in a separate file<br>
D) Deleted<br>
<br>
<b>Answer: B) Nested within the same document</b>
</details>

<details>
<summary><b>18. Relational databases are "Schema-on-______"</b></summary>
A) Read<br>
B) Write<br>
<br>
<b>Answer: B) Write (Validation happens when you save data)</b>
</details>

<details>
<summary><b>19. NoSQL databases are often "Schema-on-______"</b></summary>
A) Read<br>
B) Write<br>
<br>
<b>Answer: A) Read (Validation logic is often in the application code)</b>
</details>

<details>
<summary><b>20. Which use case is NOT ideal for standard Relational DBs?</b></summary>
A) User Accounts<br>
B) Managing Inventory<br>
C) Storing massive, unstructured IoT logs<br>
D) Processing Payments<br>
<br>
<b>Answer: C) Storing massive, unstructured IoT logs</b>
</details>

<details>
<summary><b>21. CAP Theorem states you can't satisfy which three simultaneously?</b></summary>
A) Consistency, Availability, Performance<br>
B) Consistency, Availability, Partition Tolerance<br>
C) Cost, Availability, Performance<br>
D) Consistency, Accuracy, Partitioning<br>
<br>
<b>Answer: B) Consistency, Availability, Partition Tolerance</b>
</details>
