# Amazon DynamoDB Introduction

## What is DynamoDB?

Amazon DynamoDB is a fully managed NoSQL database service that provides fast and predictable performance with seamless scalability. Unlike traditional relational databases, DynamoDB is designed for applications that need consistent, single-digit millisecond latency at any scale.

## Why Use DynamoDB?

### Traditional Database (RDS)
```
Your Responsibilities:
├── Choose instance size
├── Manage storage capacity
├── Monitor performance
├── Scale up/down manually
└── Plan for peak load

Performance: Predictable but limited by instance
Cost: Pay for provisioned capacity (always running)
```

### DynamoDB (Serverless)
```
AWS Handles:
├── ✅ Auto-scaling (up and down)
├── ✅ Storage management (unlimited)
├── ✅ Replication across AZs
├── ✅ Performance optimization
└── ✅ Backup and restore

Performance: Consistent at any scale
Cost: Pay only for what you use (on-demand) or reserve capacity
```

## Key Concepts

### Tables, Items, and Attributes

**Think of it like this**:
- **Table** = Spreadsheet
- **Item** = Row
- **Attribute** = Column (but flexible!)

```json
// Traditional Relational (rigid schema)
users_table:
  id | name    | email           | city
  ---|---------|-----------------|-------
  1  | Alice   | alice@ex.com    | NYC
  2  | Bob     | bob@ex.com      | LA

// DynamoDB (flexible schema)
users_table:
{
  "userId": "user_001",
  "name": "Alice",
  "email": "alice@example.com",
  "address": {  // → Nested object!
    "city": "NYC",
    "zip": "10001"
  },
  "preferences": ["dark-mode", "notifications"]  // → Array!
}

{
  "userId": "user_002",
  "name": "Bob",
  "email": "bob@example.com",
  "premium": true,  // → Different attributes!
  "memberSince": "2024-01-15"
}
```

### Primary Keys

Every item MUST have a unique primary key. Two types:

**1. Partition Key Only** (Simple Primary Key)
```
users_table:
  Partition Key: userId

Access pattern: Get user by userId
Query: "Give me user user_001"
```

**2. Partition Key + Sort Key** (Composite Primary Key)
```
orders_table:
  Partition Key: customerId
  Sort Key: orderDate

Access pattern: Get all orders for a customer, sorted by date
Query: "Give me all orders for customer_123 from last month"
```

### Visual Comparison

```
Partition Key Only:
┌──────────────────────────────────────┐
│ userId (PK) │ name   │  email       │
├──────────────────────────────────────┤
│ user_001    │ Alice  │ alice@e.com  │ ← Unique by userId
│ user_002    │ Bob    │ bob@e.com    │
└──────────────────────────────────────┘

Partition + Sort Key:
┌─────────────────────────────────────────────┐
│ customerId (PK) │ orderDate (SK) │ amount  │
├─────────────────────────────────────────────┤
│ cust_001        │ 2024-01-15     │ $99.99  │ ← Unique by PK+SK
│ cust_001        │ 2024-02-20     │ $149.99 │
│ cust_002        │ 2024-01-10     │ $79.99  │
└─────────────────────────────────────────────┘
```

## DynamoDB vs RDS

| Feature | RDS (Relational) | DynamoDB (NoSQL) |
|---------|------------------|------------------|
| **Schema** | Fixed, predefined | Flexible, dynamic |
| **Scaling** | Manual, limited | Automatic, unlimited |
| **Queries** | SQL, complex JOINs | Key-based, simple |
| **Performance** | Variable (depends on instance) | Consistent (single-digit ms) |
| **Transactions** | ACID across tables | ACID within partition |
| **Cost Model** | Hourly instance pricing | Pay per request or reserved |
| **Best For** | Complex relationships | High-scale key-value lookups |

## When to Use Dyn amoDB

### ✅ Perfect Use Cases

**High-Scale Web Applications**
```
Example: User sessions for millions of users
- Need: Fast reads/writes
- Scale: Millions of requests per second
- Pattern: Simple key lookups (get session by sessionId)

DynamoDB:
- Automatically scales to demand
- Consistent sub-10ms response
- Pay only for what you use
```

**Mobile/Gaming Applications**
```
Example: Game leaderboard, player data
- Need: Real-time updates
- Scale: Spiky traffic patterns
- Pattern: Get player scores, update in real-time

DynamoDB:
- On-demand scaling for game events
- Global tables for worldwide players
- Streams for real-time notifications
```

**IoT Data Storage**
```
Example: Sensor data from millions of devices
- Need: High write throughput
- Scale: Billions of data points
- Pattern: Write sensor readings, query recent data

DynamoDB:
- Handles millions of writes/second
- Time-based queries with sort keys
- Automatic data expiration (TTL)
```

**Shopping Carts**
```
Example: E-commerce cart storage
- Need: Fast read/write for cart updates
- Scale: Black Friday traffic spikes
- Pattern: Get/update cart by userId

DynamoDB:
- Instant scale during sales
- Always available
- Global replication for multi-region
```

### ❌ Not Ideal For

**Complex Reporting/Analytics**
```
Bad: SELECT AVG(price) FROM orders
      JOIN customers ON orders.customer_id = customers.id
      WHERE customers.region = 'US'
      GROUP BY order_month

Use instead: RDS or Redshift
```

**Ad-Hoc Queries**
```
Bad: "Find all users who signed up in January AND
      live in NYC AND have premium subscription"

DynamoDB: Requires careful index design for this
Use instead: RDS or Elasticsearch
```

##Data Types

DynamoDB supports various data types:

### Scalar Types
```json
{
  "string": "Hello World",
  "number": 42,
  "binary": "<base64-encoded>",
  "boolean": true,
  "null": null
}
```

### Document Types
```json
{
  "list": ["apple", "banana", "orange"],
  "map": {
    "nested": "value",
    "count": 10
  }
}
```

### Set Types
```json
{
  "stringSet": ["tag1", "tag2", "tag3"],
  "numberSet": [1, 2, 3, 5, 8],
  "binarySet": ["<base64-1>", "<base64-2>"]
}
```

## Read and Write Capacity

### On-Demand Mode (Recommended for Beginners)

**How it works**:
- Pay per request
- No capacity planning
- Automatically scales

**Pricing example**:
```
Reads: $0.25 per million requests
Writes: $1.25 per million requests

Example app with 10M reads + 2M writes per month:
Reads:  10M * $0.25 = $2.50
Writes:  2M * $1.25 = $2.50
Total: $5.00/month
```

**Best for**:
- Unknown/unpredictable traffic
- New applications
- Spiky workloads

### Provisioned Mode

**How it works**:
- Reserve capacity units
- Lower cost at scale
- Need to plan capacity

**Capacity units**:
```
1 Read Capacity Unit (RCU) = 1 strongly consistent read/sec (up to 4 KB)
1 Write Capacity Unit (WCU) = 1 write/sec (up to 1 KB)

Example: 100 RCU + 50 WCU
- Can handle 100 reads/sec + 50 writes/sec
- Cost: ~$12/month (+ storage)
```

**Best for**:
- Predictable traffic
- Cost optimization
- Large-scale apps

## DynamoDB Operations

### Basic Operations

**Put Item** (Create/Update)
```bash
aws dynamodb put-item \
  --table-name users \
  --item '{
    "userId": {"S": "user_001"},
    "name": {"S": "Alice"},
    "email": {"S": "alice@example.com"},
    "signupDate": {"S": "2024-01-15"}
  }'
```

**Get Item** (Read)
```bash
aws dynamodb get-item \
  --table-name users \
  --key '{"userId": {"S": "user_001"}}'
```

**Update Item**
```bash
aws dynamodb update-item \
  --table-name users \
  --key '{"userId": {"S": "user_001"}}' \
  --update-expression "SET #n = :name" \
  --expression-attribute-names '{"#n": "name"}' \
  --expression-attribute-values '{":name": {"S": "Alice Smith"}}'
```

**Delete Item**
```bash
aws dynamodb delete-item \
  --table-name users \
  --key '{"userId": {"S": "user_001"}}'
```

### Query vs Scan

**Query** (Efficient - use partition key)
```bash
# Find all orders for a customer
aws dynamodb query \
  --table-name orders \
  --key-condition-expression "customerId = :cust" \
  --expression-attribute-values '{":cust": {"S": "cust_001"}}'

# Cost: Reads only matching items
# Speed: Fast (uses index)
```

**Scan** (Expensive - reads entire table)
```bash
# Find all premium users (NO index on 'premium' field)
aws dynamodb scan \
  --table-name users \
  --filter-expression "premium = :true" \
  --expression-attribute-values '{":true": {"BOOL": true}}'

# Cost: Reads ENTIRE table
# Speed: Slow for large tables
# Use sparingly!
```

## Global vs Local Secondary Indexes

### Global Secondary Index (GSI)
Create alternate access patterns:

```
Base table:
  PK: userId
  Attributes: name, email, createdDate

GSI on email:
  PK: email
  Now you can query: "Find user by email"

GSI on createdDate:
  PK: createdDate
  Now you can query: "Find all users created on 2024-01-15"
```

### Local Secondary Index (LSI)
Alternate sort key for same partition:

```
Base table:
  PK: customerId
  SK: orderDate

LSI with different sort:
  PK: customerId (same)
  SK: orderAmount
  Now you can query: "Find customer's orders sorted by amount"
```

## Consistency Models

### Eventually Consistent Reads (Default)
```
Write → Primary Copy → (delay) → Replica 1, Replica 2

Read might return old data immediately after write (< 1 second)
Cost: Cheaper (half the RCUs)
Use when: Slight delays acceptable (most cases)
```

### Strongly Consistent Reads
```
Write → Primary Copy
Read → Always from Primary Copy

Read always returns latest data
Cost: 2x the RCUs
Use when: Must have latest data (inventory, transactions)
```

## DynamoDB Streams

Track changes to your table in real-time:

```
User updates profile
    ↓
DynamoDB Table
    ↓
DynamoDB Stream (change log)
    ↓
Lambda Function (triggered)
    ↓
Send welcome email, update search index, etc.
```

**Use cases**:
- Real-time notifications
- Data replication
- Audit logging
- Search index updates

## Time To Live (TTL)

Automatically delete old items:

```json
{
  "sessionId": "sess_12345",
  "userId": "user_001",
  "expirationTime": 1736899200  // Unix timestamp
}

// DynamoDB automatically deletes when
// current time > expirationTime

// Perfect for:
// - Session data
// - Temporary tokens
// - Old logs
```

## Global Tables

Multi-region replication for worldwide apps:

```
US-East-1 (Primary)
    ↓ (replicate)
EU-West-1 (Replica)
    ↓ (replicate)
AP-Southeast-1 (Replica)

Benefits:
- Low latency worldwide
- Disaster recovery
- Active-active (write anywhere)
```

## Cost Estimation

### Small App Example
```
Traffic: 1M reads + 100K writes per month
On-Demand pricing:
- Reads: 1M * $0.25 = $0.25
- Writes: 100K * $1.25 = $0.125
- Storage (1 GB): $0.25
Total: ~$0.63/month
```

### Medium App Example
```
Traffic: 100M reads + 20M writes per month
On-Demand:
- Reads: 100M * $0.25 = $25
- Writes: 20M * $1.25 = $25
- Storage (50 GB): $12.50
Total: ~$62.50/month
```

## Quick Comparison Table

| Feature | DynamoDB | RDS MySQL |
|---------|----------|-----------|
| **Setup time** | 2 minutes | 10 minutes |
| **Scaling** | Automatic | Manual |
| **Max throughput** | Unlimited | Limited by instance |
| **Query language** | Key-based / PartiQL | SQL |
| **Schema changes** | Instant | Migration required |
| **Backups** | Automatic, point-in-time | Manual/automated |
| **Multi-region** | Global Tables | Read replicas |
| **Starting cost** | $0 (Free Tier: 25 GB) | $15/month |

## Best Practices

### ✅ Do's

1. **Use on-demand for variable traffic**
2. **Design partition keys for even distribution**
3. **Use GSIs for alternate access patterns**
4. **Enable point-in-time recovery**
5. **Use TTL for temporary data**
6. **Monitor with CloudWatch**

### ❌ Don'ts

1. **Don't use Scan for production queries**
2. **Don't create "hot" partition keys (celebrity problem)**
3. **Don't store large items (> 100 KB)**
4. **Don't use DynamoDB for complex analytics**
5. **Don't forget to set up alarms**

## Free Tier

AWS Free Tier includes:
- **25 GB of storage**
- **25 WCUs (write capacity units)**
- **25 RCUs (read capacity units)**
- **2.5M stream read requests**

**Enough for**:
- Small app with 1M requests/month
- Learning and development
- Prototypes and MVPs

## Next Steps

Ready to create your first DynamoDB table?

1. **[DynamoDB Getting Started](./dynamodb-getting-started.md)** - Hands-on tutorial
2. **[DynamoDB Tables & Items](./dynamodb-tables-items.md)** - Deep dive into data modeling
3. **[Intermediate DynamoDB](../../Intermediate-Level/09-Database-Services/02-DynamoDB-Advanced/)** - Advanced patterns

## Summary

**DynamoDB is perfect when you need**:
- 🚀 Automatic scaling
- ⚡ Consistent sub-10ms performance
- 💰 Pay-per-use pricing
- 🌍 Global distribution
- 🔧 Zero server management

**Skip DynamoDB if you need**:
- Complex SQL queries and JOINs
- Ad-hoc analytics
- Frequent schema changes
- Traditional relational model

---

**Pro Tip**: Start with DynamoDB on-demand mode - you only pay for what you use, and it automatically scales to handle any load!
