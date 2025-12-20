# Choosing the Right Database Type

## Decision Framework

This guide provides a practical decision-making framework to help you choose the appropriate database for your specific use case.

## Start Here: Decision Tree

```
Do you need strong ACID transactions?
├─ YES → Do you have complex relationships between data?
│        ├─ YES → **Relational (RDS/Aurora)**
│        └─ NO → Could be either, consider other factors ↓
│
└─ NO → Is your data highly structured?
         ├─ YES → Do you need complex queries/reports?
         │        ├─ YES → **Relational (RDS)**
         │        └─ NO → **NoSQL (DynamoDB)**
         │
         └─ NO → What type of data do you have?
                  ├─ Key-Value pairs → **DynamoDB**
                  ├─ JSON documents → **DocumentDB or DynamoDB**
                  ├─ Time-series → **DynamoDB** or **Timestream**
                  ├─ Relationships/Graphs → **Neptune**
                  └─ Caching → **ElastiCache**
```

## Quick Reference Matrix

![Quick Reference Matrix](refMatrix.png)

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
![Quick Guidelines](../../images/sumGuidelines.png)

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

Consider: What would you use RDS for? DynamoDB? Other services?
