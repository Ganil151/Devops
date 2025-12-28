## Decision Framework

This guide provides a practical decision-making framework to help you choose the appropriate database for your specific use case.

## Start Here: Decision Tree
![Decision Tree](decisionTree.png)

## Quick Reference Matrix

| Feature              | **RDS / Aurora**                    | **DynamoDB**                                | **ElastiCache**                            | **Neptune**                             | **Redshift**                             |
| :------------------- | :---------------------------------- | :------------------------------------------ | :----------------------------------------- | :-------------------------------------- | :--------------------------------------- |
| **Type**             | Relational (SQL)                    | NoSQL (Key-Value)                           | In-Memory                                  | Graph                                   | Data Warehouse                           |
| **Primary Use Case** | ERP, CRM, E-commerce, Financials    | Mobile backends, Gaming, IoT, Session store | Caching, Leaderboards, Real-time analytics | Social networks, Recommendation engines | BI, Reporting, Analytics                 |
| **Data Model**       | Tables, Rows, Foreign Keys          | Items, Attributes (Schema-less)             | Key-Value, Redis structures                | Nodes, Edges, Properties                | Columnar Storage                         |
| **Scaling**          | Vertical (Scale Up) / Read Replicas | Horizontal (Partitioning)                   | Horizontal (Sharding)                      | Read Replicas                           | Horizontal (Massive Parallel Processing) |
| **Performance**      | High (ms)                           | Extremely High (single-digit ms)            | Ultra High (micro-sec)                     | High for relationships                  | High for aggregations                    |
| **Consistency**      | Strong (ACID)                       | Eventual (Strong optional)                  | Eventual / Strong                          | Eventual / Strong                       | Eventual                                 |
| **Cost Model**       | Instance-based                      | Provisioned or Pay-per-request              | Instance-based                             | Instance-based                          | Instance-based                           |
|                      |                                     |                                             |                                            |                                         |                                          |

## Detailed Use Case Analysis

### 1. E-Commerce Application
**Scenario**: Building an online store with products, customers, orders, and inventory.

#### Components Breakdown:

**Use Relational (Aurora/RDS) for**:
- ✅ Order transactions (ACID required)
- ✅ Payment processing
- ✅ Inventory management (stock levels)
- ✅ Customer accounts
- ✅ Financial reporting

```sql
-- Strong consistency needed for inventory
BEGIN TRANSACTION;
  UPDATE inventory SET quantity = quantity - 1 WHERE product_id = 123;
  INSERT INTO orders (customer_id, product_id, quantity) VALUES (456, 123, 1);
COMMIT;
```

**Use NoSQL (DynamoDB) for**:
- ✅ Product catalog (products have different attributes)
- ✅ Shopping carts (temporary, high throughput)
- ✅ User reviews and ratings
- ✅ Browsing history
- ✅ Product recommendations

```json
{
  "productId": "laptop_001",
  "name": "Gaming Laptop",
  "category": "Electronics",
  "specs": {
    "cpu": "Intel i9",
    "ram": "32GB",
    "gpu": "RTX 4090"
  },
  "reviews": [...]
}
```

### 2. Social Media Platform
**Scenario**: Build a social networking site with profiles, posts, friendships, and messaging.
#### Recommended Architecture:
**Relational (RDS) - 20%**:
- User authentication and credentials
- Billing and subscriptions
- Admin dashboards

**NoSQL (DynamoDB) - 60%**:
- User profiles
- Posts and comments
- Activity feeds
- Notifications
- Direct messages

**Graph (Neptune) - 20%**:
- Friend connections
- Followers/following relationships
- Content recommendations
- Influence analysis

```
Why this split?
- Relational: Critical auth/billing needs ACID
- NoSQL: High-volume, flexible schema for user content
- Graph: Relationship queries (mutual friends, suggestions)
```

### 3. Banking Application

**Scenario**: Core banking system with accounts, transactions, and reporting.

**Recommendation**: **Relational Only (Aurora PostgreSQL)**

**Why**:
- ✅ ACID transactions are absolutely critical
- ✅ Money transfers must be atomic
- ✅ Audit trails required
- ✅ Complex financial reporting
- ✅ Regulatory compliance

```sql
-- Atomic money transfer
BEGIN TRANSACTION;
  UPDATE accounts SET balance = balance - 500 WHERE id = 'ACC001';
  UPDATE accounts SET balance = balance + 500 WHERE id = 'ACC002';
  INSERT INTO audit_log VALUES (NOW(), 'TRANSFER', 500, 'ACC001', 'ACC002');
COMMIT;
```

**Optional NoSQL Components**:
- ElastiCache for session management
- DynamoDB for mobile app push notifications
- But core banking = Relational

### 4. IoT Sensor Network

**Scenario**: Collecting data from thousands of sensors sending readings every second.

**Recommendation**: **NoSQL (DynamoDB or Timestream)**

**Why**:
- ✅ Millions of writes per second
- ✅ Time-series data
- ✅ Horizontal scaling required
- ✅ No complex relationships
- ✅ Flexible schema (different sensor types)

```json
{
  "sensorId": "temp_sensor_1001",
  "timestamp": "2024-01-15T10:30:45Z",
  "readings": {
    "temperature": 22.5,
    "humidity": 65,
    "pressure": 1013.25
  },
  "location": {"lat": 40.7128, "lon": -74.0060}
}
```

### 5. Content Management System

**Scenario**: Blog platform with articles, authors, comments, and media.

**Recommendation**: **Hybrid - DocumentDB (primary) + RDS (optional)**

**DocumentDB/DynamoDB for**:
- ✅ Article content (rich media, varying structure)
- ✅ User comments
- ✅ Tags and categories
- ✅ Media metadata

```json
{
  "articleId": "post_12345",
  "title": "Getting Started with AWS",
  "author": {"name": "Alice", "id": "author_456"},
  "content": "...",
  "tags": ["aws", "cloud", "tutorial"],
  "publishedAt": "2024-01-15",
  "media": [
    {"type": "image", "url": "...", "caption": "..."},
    {"type": "video", "url": "...", "duration": 120}
  ],
  "comments": [...]
}
```

**RDS for** (optional):
- User authentication
- Author management
- Analytics

## Key Decision Factors

### 1. Data Structure

**Highly Structured** → *Relational*
```
Example: Employee database
- Every employee has: ID, name, department, salary, hire_date
- Clear relationships: employee → department → manager
```

**Variable Structure** → *NoSQL*
```
Example: Product catalog
- Electronics: brand, model, specs, warranty
- Clothing: size, color, material, care_instructions
- Books: author, pages, publisher, ISBN
```

### 2. Consistency Requirements

**Strong Consistency Needed** → *Relational*
- Financial transactions
- Inventory management
- Booking systems (no double-booking)

**Eventual Consistency OK** → *NoSQL*
- Social media likes
- View counts
- Product recommendations

### 3. Query Patterns

**Complex Queries with JOINs** → *Relational*
```sql
-- Complex report across multiple tables
SELECT 
  d.name AS department,
  COUNT(e.id) AS employee_count,
  AVG(e.salary) AS avg_salary
FROM departments d
LEFT JOIN employees e ON d.id = e.department_id
WHERE e.hire_date > '2023-01-01'
GROUP BY d.name
HAVING COUNT(e.id) > 10
ORDER BY avg_salary DESC;
```

**Simple Key-Based Lookups** → *NoSQL*
```python
# Fast single-item retrieval
get_item(
  TableName='Users',
  Key={'userId': 'user_12345'}
)
```

### 4. Scale Requirements

**Moderate Scale** (< 10K requests/second) → *Either*

**High Scale** (> 100K requests/second) → *NoSQL*
- DynamoDB can handle millions of requests/second
- Automatic horizontal scaling

**Predictable Growth** → *Relational*

**Unpredictable Spikes** → *NoSQL*

### 5. Development Speed

**Need Rapid Prototyping** → *NoSQL*
- No schema migrations
- Flexible data model
- Quick iterations

**Stable Requirements** → *Relational*
- Well-defined schema
- Enforced constraints
- Gradual changes

## Common Anti-Patterns to Avoid

### ❌ Using NoSQL for Everything
**Don't**: Use DynamoDB for a simple CRUD app with clear relationships

**Problem**: Lose referential integrity, complex queries become application logic

**Better**: Use RDS for straightforward relational data

### ❌ Using Relational for High-Scale Key-Value
**Don't**: Use RDS to store millions of session records

**Problem**: Poor performance, scaling challenges, high cost

**Better**: Use ElastiCache or DynamoDB

### ❌ Ignoring Hybrid Approaches
**Don't**: Force one database type for all use cases

**Problem**: Suboptimal performance or costly workarounds

**Better**: Use the right tool for each job

### ❌ Premature Optimization
**Don't**: Choose NoSQL "because it scales" for a startup MVP

**Problem**: Added complexity without proven need

**Better**: Start with what you know (often RDS), scale when needed

## Decision Checklist

Answer these questions to guide your choice:

- [ ] **Do I need ACID transactions?** → YES = Relational
- [ ] **Is my schema fixed and stable?** → YES = Relational
- [ ] **Do I need complex JOINs and aggregations?** → YES = Relational
- [ ] **Will I have millions of requests/second?** → YES = NoSQL
- [ ] **Is my data structure flexible/varying?** → YES = NoSQL
- [ ] **Do I need to iterate quickly on schema?** → YES = NoSQL
- [ ] **Is my data primarily key-value lookups?** → YES = NoSQL
- [ ] **Do I need graph relationships?** → YES = Neptune
- [ ] **Is this primarily for caching?** → YES = ElastiCache

## Cost Considerations

### RDS/Aurora
**Pros**: Predictable pricing, reserved instances  
**Cons**: Pay for provisioned capacity even if unused

**Best for**: Steady, predictable workloads

### DynamoDB
**Pros**: Pay-per-request, true serverless, auto-scaling  
**Cons**: Can be expensive at very high volumes

**Best for**: Variable workloads, serverless applications

## Migration Path

### Starting Point

**New Project**:
1. Start simple (usually RDS)
2. Add NoSQL as specific needs arise
3. Don't over-engineer

**Existing Application**:
1. Identify bottlenecks
2. Extract high-throughput components
3. Gradually migrate to NoSQL
4. Keep core transactional data in RDS

## Summary: Quick Guidelines
## Summary: Quick Guidelines

1.  **Default to RDS/Aurora** if your data fits in a spreadsheet (rows/columns) and you need transactions.
2.  **Choose DynamoDB** if you need unlimited scale, flexible schema, or simple key-value patterns.
3.  **Add ElastiCache** if you need sub-millisecond speed for frequently accessed data.
4.  **Use Redshift** only for analytics (OLAP), not for the live application (OLTP).
5.  **Use Neptune** only if relationships are more important than the data itself (graphs).

## Next Steps

Ready to implement? Choose your path:

- **Relational Path**: [RDS Introduction](../02-RDS-Basics/rds-introduction.md)
- **NoSQL Path**: [DynamoDB Introduction](../03-DynamoDB-Basics/dynamodb-introduction.md)
- **Need Both**: Start with RDS, add DynamoDB as needed

---

**Exercise**: Design the database architecture for these applications:

1. **Food delivery app** (restaurants, orders, delivery tracking)
2. **Video streaming platform** (users, videos, watch history, recommendations)
3. **Project management tool** (teams, tasks, timelines, comments)


---

## Part 2: Advanced Real-World Scenarios

### Scenario 1: The "Viral" Mobile Game
**Situation:** A mobile game stores player scores and profiles in MySQL. It goes viral, reaching 1 million daily active users. The single database server hits 100% CPU due to millions of small updates (score changes, inventory pickups).
**Decision:** **Switch to NoSQL (DynamoDB/Redis)**
**Reasoning:**
- **Access Pattern:** High volume of small, fast writes. Key-based lookup (get player profile).
- **Scale:** Unpredictable viral growth demands horizontal scaling.
- **Consistency:** Eventual consistency is fine for leaderboards (if a score shows up 1 second late, nobody dies).

### Scenario 2: The Healthcare Patient Portal
**Situation:** A hospital needs a system to store patient medical history, billing, and insurance claims.
**Decision:** **Stick with Relational (Aurora PostgreSQL)**
**Reasoning:**
- **Data Integrity:** Life-critical data. ACID transactions are non-negotiable.
- **Complexity:** Complex relationships between Patients, Doctors, Appointments, Prescriptions, and Billing.
- **Compliance:** Regulatory requirements (HIPAA) often favor established relational audit trails.

### Scenario 3: The "Feed" Architecture
**Situation:** A news aggregation app needs to show a custom feed to each user based on who they follow and their interests.
**Decision:** **Hybrid (Graph + Key-Value)**
**Reasoning:**
- **Graph (Neptune):** Determine *what* to show (Who do I follow? What do they like?). Graph traversals are efficient here.
- **Key-Value (DynamoDB):** Store the actual content of the posts (or the pre-computed feed) for fast retrieval.

---

## Part 3: Interview Questions

### Basic Level
1.  **When would you choose a NoSQL database over a Relational one?**
    -   When I need massive horizontal scale, flexible schemas (rapid iteration), or have specific data models like graphs or documents that map poorly to tables.
2.  **What is the "N+1 Problem" in relational databases?**
    -   It happens when data is fetched in a loop. For example, fetching 100 users (1 query) and then running a separate query for each user's address (100 queries). This kills performance. NoSQL avoids this by embedding data (storing address *with* the user).
3.  **What is a "Read Replica"?**
    -   A copy of the primary database that can handle read-only traffic. It offloads work from the main database but might be slightly out of sync (eventual consistency).

### Intermediate Level
4.  **Explain "Polyglot Persistence".**
    -   Using different databases for different parts of an application typically based on the specific needs of each component (e.g., Redis for caching, PostgreSQL for payments, Mongo for catalog).
5.  **What is the trade-off of "Denormalization"?**
    -   **Benefit:** Faster reads (no joins needed).
    -   **Cost:** Slower writes (update data in multiple places) and risk of data inconsistency (updates might fail in one spot).

---

## Part 4: Knowledge Quiz

<details>
<summary><b>1. Which feature implies a Relational Database is the best choice?</b></summary>
A) Flexible Schema<br>
B) Unstructured Data<br>
C) Complex relationships & JOINs<br>
D) Infinite horizontal scaling<br>
<br>
<b>Answer: C) Complex relationships & JOINs</b>
</details>

<details>
<summary><b>2. If your application requires handling millions of requests per second with single-digit millisecond latency, choose:</b></summary>
A) Redshift<br>
B) DynamoDB (NoSQL)<br>
C) RDS (Relational)<br>
D) Glacier<br>
<br>
<b>Answer: B) DynamoDB (NoSQL)</b>
</details>

<details>
<summary><b>3. E-Commerce Order Processing (Payments) typically requires:</b></summary>
A) Eventual Consistency<br>
B) Strong ACID Transactions<br>
C) Graph relationships<br>
D) Approximate correctness<br>
<br>
<b>Answer: B) Strong ACID Transactions</b>
</details>

<details>
<summary><b>4. Which is a valid reason to choose NoSQL?</b></summary>
A) You love writing SQL<br>
B) Your data schema changes constantly (e.g., varying product attributes)<br>
C) You need complex reporting<br>
D) You have very little data<br>
<br>
<b>Answer: B) Your data schema changes constantly</b>
</details>

<details>
<summary><b>5. For a recommendation engine (e.g., "People who bought this also bought..."), the best specialized DB is:</b></summary>
A) Key-Value<br>
B) Document<br>
C) Graph (Neptune)<br>
D) Relational<br>
<br>
<b>Answer: C) Graph (Neptune)</b>
</details>

<details>
<summary><b>6. What is the primary use case for Amazon ElastiCache?</b></summary>
A) Long-term archival<br>
B) In-memory caching to speed up read-heavy workloads<br>
C) Complex transactions<br>
D) Video storage<br>
<br>
<b>Answer: B) In-memory caching to speed up read-heavy workloads</b>
</details>

<details>
<summary><b>7. "Data Warehousing" (like Redshift) is optimized for:</b></summary>
A) Transaction processing (OLTP)<br>
B) Analytical processing (OLAP) & massive aggregations<br>
C) Real-time chat<br>
D) Session management<br>
<br>
<b>Answer: B) Analytical processing (OLAP) & massive aggregations</b>
</details>

<details>
<summary><b>8. Which is an example of "structured" data?</b></summary>
A) A tweet<br>
B) A video file<br>
C) An employee record with fixed fields (ID, Name, Dept)<br>
D) A blog post<br>
<br>
<b>Answer: C) An employee record with fixed fields</b>
</details>

<details>
<summary><b>9. If you need to search through petabytes of text logs, use:</b></summary>
A) RDS<br>
B) OpenSearch / Elasticsearch<br>
C) ElastiCache<br>
D) Neptune<br>
<br>
<b>Answer: B) OpenSearch / Elasticsearch</b>
</details>

<details>
<summary><b>10. A major cost factor for DynamoDB is:</b></summary>
A) Number of Tables<br>
B) Read/Write Capacity Units (Throughput)<br>
C) Number of users<br>
D) Idle time<br>
<br>
<b>Answer: B) Read/Write Capacity Units (Throughput)</b>
</details>

<details>
<summary><b>11. Relational Databases scale best:</b></summary>
A) Vertically (Scale Up)<br>
B) Horizontally (Scale Out)<br>
C) Diagonally<br>
D) Randomly<br>
<br>
<b>Answer: A) Vertically (Scale Up)</b>
</details>

<details>
<summary><b>12. You need to store "Session State" for a web app. Best choice?</b></summary>
A) Redshift<br>
B) Key-Value Store (Redis/DynamoDB)<br>
C) Graph DB<br>
D) Cold Storage<br>
<br>
<b>Answer: B) Key-Value Store (Redis/DynamoDB)</b>
</details>

<details>
<summary><b>13. Which scenario might force a migration from NoSQL back to SQL?</b></summary>
A) Need for faster reads<br>
B) Need for strict regulatory compliance, audit trails, and complex reporting<br>
C) Need for more flexibility<br>
D) Need for horizontal scaling<br>
<br>
<b>Answer: B) Need for strict regulatory compliance, audit trails, and complex reporting</b>
</details>

<details>
<summary><b>14. "Time Series" data (like sensor readings) is best stored in:</b></summary>
A) A specialized Time Series DB (Timestream) or Column store<br>
B) A Graph DB<br>
C) A Cache<br>
D) A Ledger<br>
<br>
<b>Answer: A) A specialized Time Series DB (Timestream) or Column store</b>
</details>

<details>
<summary><b>15. Why avoid "Premature Optimization"?</b></summary>
A) Checklists are bad<br>
B) You shouldn't pick a complex NoSQL system if a simple SQL setup works fine initially<br>
C) SQL is always faster<br>
D) NoSQL is always cheaper<br>
<br>
<b>Answer: B) You shouldn't pick a complex NoSQL system if a simple SQL setup works fine initially</b>
</details>

<details>
<summary><b>16. Which ensures "Referential Integrity"?</b></summary>
A) Foreign Keys (Relational)<br>
B) Embedding Data (NoSQL)<br>
C) Sharding<br>
D) Caching<br>
<br>
<b>Answer: A) Foreign Keys (Relational)</b>
</details>

<details>
<summary><b>17. ACID stands for:</b></summary>
A) Atomicity, Consistency, Isolation, Durability<br>
B) Accuracy, Cost, Integrity, Data<br>
C) Availability, Consistency, Isolation, Database<br>
D) Always Check Integrity Daily<br>
<br>
<b>Answer: A) Atomicity, Consistency, Isolation, Durability</b>
</details>

<details>
<summary><b>18. In the CAP theorem, which property do distributed NoSQL databases typically sacrifice?</b></summary>
A) Partition Tolerance<br>
B) Availability (sometimes)<br>
C) Strong Consistency (often)<br>
D) Speed<br>
<br>
<b>Answer: C) Strong Consistency (often)</b>
</details>

<details>
<summary><b>19. Hybrid architectures involve:</b></summary>
A) Using paper and digital<br>
B) Using multiple specialized databases (Polyglot Persistence)<br>
C) Using only one database for everything<br>
D) Using Excel as a database<br>
<br>
<b>Answer: B) Using multiple specialized databases (Polyglot Persistence)</b>
</details>

<details>
<summary><b>20. Which cost model allows "Pay per Request"?</b></summary>
A) RDS Provisioned<br>
B) DynamoDB On-Demand<br>
C) Reserved Instances<br>
D) Dedicated Host<br>
<br>
<b>Answer: B) DynamoDB On-Demand</b>
</details>

<details>
<summary><b>21. "Schema Migration" is a pain point primarily for:</b></summary>
A) NoSQL<br>
B) Relational Databases<br>
C) Key-Value Stores<br>
D) Flat files<br>
<br>
<b>Answer: B) Relational Databases</b>
</details>
