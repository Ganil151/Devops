# Database Concepts and Fundamentals

## What is a Database?

A database is an organized collection of structured data that is stored electronically and accessed through a computer system. Databases are managed by Database Management Systems (DBMS) which provide an interface for storing, retrieving, and manipulating data efficiently.

### Why Use Databases?

```
Traditional File Storage        Database Management System
┌────────────────────┐         ┌────────────────────┐
│  file1.txt         │         │                    │
│  file2.csv         │   VS    │    Structured      │
│  data.json         │         │    Organized       │
│  backup_old.txt    │         │    Queryable       │
└────────────────────┘         │    Consistent      │
  ❌ Disorganized               └────────────────────┘
  ❌ Redundant                    ✅ Single source of truth
  ❌ Hard to query                ✅ ACID properties
  ❌ Inconsistent                 ✅ Concurrent access
```

**Key Benefits:**
- **Data Integrity**: Ensures data accuracy and consistency
- **Data Security**: Controlled access and encryption
- **Concurrent Access**: Multiple users can access simultaneously
- **Backup and Recovery**: Automated data protection
- **Scalability**: Handle growing data volumes
- **Query Capability**: Efficiently search and retrieve data

## Database Types Overview

### 1. Relational Databases (SQL)

Organized in tables with rows and columns, using Structured Query Language (SQL).

```
Users Table                    Orders Table
┌────┬──────────┬───────────┐  ┌────┬─────────┬────────┬────────┐
│ ID │ Name     │ Email     │  │ ID │ User_ID │ Amount │ Date   │
├────┼──────────┼───────────┤  ├────┼─────────┼────────┼────────┤
│ 1  │ Alice    │ a@ex.com  │  │ 1  │ 1       │ 99.99  │ 2024-01│
│ 2  │ Bob      │ b@ex.com  │  │ 2  │ 1       │ 149.99 │ 2024-02│
│ 3  │ Charlie  │ c@ex.com  │  │ 3  │ 2       │ 79.99  │ 2024-02│
└────┴──────────┴───────────┘  └────┴─────────┴────────┴────────┘
         ↑                               ↑
         └───────────────────────────────┘
              Foreign Key Relationship
```

**Examples**: MySQL, PostgreSQL, Oracle, SQL Server, MariaDB

**Best For**:
- Financial transactions
- Customer relationship management (CRM)
- Enterprise resource planning (ERP)
- Applications requiring complex queries and joins

### 2. NoSQL Databases

Flexible, non-tabular databases designed for large-scale data storage.

#### Key-Value Stores
```json
{
  "user:1001": {
    "name": "Alice",
    "email": "alice@example.com",
    "preferences": {"theme": "dark", "language": "en"}
  },
  "session:abcd1234": {
    "userId": 1001,
    "expires": "2024-12-31T23:59:59Z"
  }
}
```
**Examples**: DynamoDB, Redis  
**Best For**: Caching, session management, user preferences

#### Document Stores
```json
{
  "_id": "product123",
  "name": "Laptop",
  "price": 999.99,
  "specs": {
    "cpu": "Intel i7",
    "ram": "16GB",
    "storage": ["512GB SSD", "1TB HDD"]
  },
  "reviews": [
    {"user": "alice", "rating": 5, "comment": "Great!"},
    {"user": "bob", "rating": 4, "comment": "Good value"}
  ]
}
```
**Examples**: MongoDB, DocumentDB  
**Best For**: Content management, catalogs, user profiles

#### Column-Family Stores
```
Row Key    │ Column Family: Profile          │ Column Family: Activity
───────────┼──────────────────────────────────┼───────────────────────
user:1001  │ name:Alice, email:a@ex.com      │ lastLogin:2024-01-15
user:1002  │ name:Bob, email:b@ex.com        │ lastLogin:2024-01-14
```
**Examples**: Cassandra, HBase  
**Best For**: Time-series data, IoT applications

#### Graph Databases
```
    (Alice)───[FRIENDS_WITH]───(Bob)
       │                          │
   [LIKES]                    [BOUGHT]
       │                          │
       ↓                          ↓
   (Product A)←────[SOLD]────(Store X)
```
**Examples**: Neptune, Neo4j  
**Best For**: Social networks, recommendation engines, fraud detection

## ACID Properties

ACID ensures database transactions are processed reliably:

### **A**tomicity
All operations in a transaction succeed or all fail together.

```sql
BEGIN TRANSACTION;
  UPDATE accounts SET balance = balance - 100 WHERE id = 1;
  UPDATE accounts SET balance = balance + 100 WHERE id = 2;
COMMIT; -- Both succeed or both fail
```

If the system crashes after the first UPDATE, the entire transaction rolls back.

### **C**onsistency
Database remains in a valid state before and after transactions.

```
Before: Account1 = $1000, Account2 = $500, Total = $1500
Transfer $100 from Account1 to Account2
After: Account1 = $900, Account2 = $600, Total = $1500 ✅
```

### **I**solation
Concurrent transactions don't interfere with each other.

```
Transaction 1: Read balance → Withdraw $100 → Write new balance
Transaction 2: Read balance → Withdraw $50 → Write new balance

Without isolation: Both read $1000, both withdraw, final balance wrong ❌
With isolation: Transactions execute sequentially or safely ✅
```

### **D**urability
Committed transactions persist even after system failures.

```
1. User transfers money ✅
2. System confirms "Transaction successful"
3. Power outage! 💥
4. System restarts
5. Transaction still recorded ✅
```

## CAP Theorem

In distributed databases, you can only guarantee 2 out of 3:

```
        Consistency
            / \
           /   \
          /     \
         /       \
        /         \
Availability -- Partition Tolerance

Choose 2:
CP: Consistent + Partition tolerant (sacrifice availability)
AP: Available + Partition tolerant (sacrifice consistency)
CA: Consistent + Available (not viable in distributed systems)
```

### Trade-offs:
- **CP Systems**: Banking (must be consistent, can sacrifice availability)
- **AP Systems**: Social media feeds (prefer availability, eventual consistency OK)
- **AWS Examples**:
  - **RDS**: CP (strong consistency, may not be available during failures)
  - **DynamoDB**: AP by default (eventually consistent, highly available)

## Database Components

### Schema
The blueprint defining database structure:

```sql
CREATE TABLE users (
  id INT PRIMARY KEY,
  username VARCHAR(50) NOT NULL,
  email VARCHAR(100) UNIQUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT chk_email CHECK (email LIKE '%@%')
);
```

### Tables
Organized collections of related data:
- **Columns**: Attributes/fields
- **Rows**: Individual records
- **Primary Key**: Unique identifier for each row
- **Foreign Key**: References another table's primary key

### Indexes
Speed up data retrieval:

```sql
-- Without index: Scans entire table
SELECT * FROM users WHERE email = 'alice@example.com';

-- With index: Direct lookup
CREATE INDEX idx_email ON users(email);
SELECT * FROM users WHERE email = 'alice@example.com'; -- Much faster!
```

**Trade-off**: Faster reads, slower writes (index must be updated)

### Transactions
Groups of operations that execute as a single unit:

```sql
START TRANSACTION;
  INSERT INTO orders (user_id, total) VALUES (1, 99.99);
  UPDATE inventory SET quantity = quantity - 1 WHERE product_id = 100;
  INSERT INTO audit_log (action, timestamp) VALUES ('order_placed', NOW());
COMMIT; -- All or nothing
```

## Common Database Operations (CRUD)

### Create
```sql
INSERT INTO products (name, price, category)
VALUES ('Laptop', 999.99, 'Electronics');
```

### Read
```sql
-- Select all
SELECT * FROM products;

-- Select specific
SELECT name, price FROM products WHERE category = 'Electronics';

-- With joins
SELECT orders.id, users.name, orders.total
FROM orders
JOIN users ON orders.user_id = users.id;
```

### Update
```sql
UPDATE products
SET price = 899.99
WHERE name = 'Laptop';
```

### Delete
```sql
DELETE FROM products
WHERE id = 5;
```

## Database Design Best Practices

### 1. Normalization
Organize data to reduce redundancy:

**Before (Denormalized)**:
```
Orders Table
┌────┬──────────┬───────────┬─────────┬──────────┐
│ ID │ Customer │ Cust_Email│ Product │ Price    │
├────┼──────────┼───────────┼─────────┼──────────┤
│ 1  │ Alice    │ a@ex.com  │ Laptop  │ 999.99   │
│ 2  │ Alice    │ a@ex.com  │ Mouse   │ 29.99    │  ← Email repeated
│ 3  │ Bob      │ b@ex.com  │ Laptop  │ 999.99   │  ← Price repeated
└────┴──────────┴───────────┴─────────┴──────────┘
```

**After (Normalized)**:
```
Customers                 Orders                   Products
┌────┬───────┬────────┐  ┌────┬──────────┬────────┐  ┌────┬────────┬──────┐
│ ID │ Name  │ Email  │  │ ID │ Cust_ID  │ Prod_ID│  │ ID │ Name   │ Price│
├────┼───────┼────────┤  ├────┼──────────┼────────┤  ├────┼────────┼──────┤
│ 1  │ Alice │ a@ex...│  │ 1  │ 1        │ 1      │  │ 1  │ Laptop │ 999  │
│ 2  │ Bob   │ b@ex...│  │ 2  │ 1        │ 2      │  │ 2  │ Mouse  │ 29   │
└────┴───────┴────────┘  │ 3  │ 2        │ 1      │  └────┴────────┴──────┘
                         └────┴──────────┴────────┘
```

### 2. Use Appropriate Data Types
```sql
-- Good
CREATE TABLE users (
  id INT,                    -- Integer for IDs
  email VARCHAR(255),        -- Variable length for emails
  age TINYINT,              -- Small integer for age
  created_at TIMESTAMP      -- Timestamp for dates
);

-- Bad
CREATE TABLE users (
  id VARCHAR(100),          -- ❌ Wastes space, slower
  email TEXT,               -- ❌ Overkill for emails
  age VARCHAR(10),          -- ❌ Should be numeric
  created_at VARCHAR(50)    -- ❌ Can't do date operations
);
```

### 3. Define Constraints
```sql
CREATE TABLE products (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,           -- Required field
  price DECIMAL(10,2) CHECK (price > 0), -- Must be positive
  stock INT DEFAULT 0,                   -- Default value
  category_id INT,
  FOREIGN KEY (category_id) REFERENCES categories(id)
);
```

## When to Use Databases vs Files

### Use Databases When:
- ✅ Need complex queries and relationships
- ✅ Multiple users need concurrent access
- ✅ Data integrity is critical
- ✅ Need transactional guarantees
- ✅ Data size is large and growing

### Use Files When:
- ✅ Simple, sequential data access
- ✅ Storing binary data (images, videos)
- ✅ Configuration files
- ✅ Temporary data or caching
- ✅ Single-user applications

## AWS Database Services Overview

| Service | Type | Best For |
|---------|------|----------|
| **RDS** | Relational | Traditional applications, complex queries |
| **Aurora** | Relational | High-performance MySQL/PostgreSQL |
| **DynamoDB** | NoSQL (Key-Value) | Serverless, high-scale applications |
| **DocumentDB** | NoSQL (Document) | MongoDB workloads |
| **ElastiCache** | In-Memory | Caching, session store |
| **Redshift** | Data Warehouse | Analytics, BI |
| **Neptune** | Graph | Recommendation engines |

## Next Steps

Now that you understand database fundamentals, continue your learning:

1. **[Relational vs NoSQL](./relational-vs-nosql.md)** - Deep dive into choosing the right database type
2. **[Choosing Database Type](./choosing-database-type.md)** - Decision framework for your use case
3. **[RDS Introduction](../02-RDS-Basics/rds-introduction.md)** - Start with AWS managed relational databases

## Key Takeaways

- 📊 Databases provide structured, reliable data storage
- 🔒 ACID properties ensure transaction reliability
- 🏗️ Choose relational for structured data with relationships
- 🚀 Choose NoSQL for flexible, scalable applications
- 🛠️ AWS offers managed services for all database types
- ⚖️ CAP theorem: understand trade-offs in distributed systems

---

**Practice Exercise**: Think about an application you use daily. What type of database would it use and why? Consider the data structure, access patterns, and consistency requirements.
