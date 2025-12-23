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

- **[Choosing Database Type](./choosing-database-type.md)** - Practical decision guide
- **[RDS Introduction](../02-RDS-Basics/rds-introduction.md)** - Start with relational databases
- **[DynamoDB Introduction](../03-DynamoDB-Basics/dynamodb-introduction.md)** - Explore NoSQL

---

**Quick Quiz**: For each scenario, which database type would you choose?
1. Banking transaction system
2. Real-time gaming leaderboard
3. E-commerce product catalog with varying attributes
4. Hospital patient records
5. Social media user feeds

**Answers**: 1) Relational, 2) NoSQL, 3) NoSQL, 4) Relational, 5) NoSQL (hybrid)
