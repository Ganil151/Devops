# Database Interview Questions & Quiz

Master the art of managing data at scale and prepare for technical DevOps and SRE interviews.

---

## 🎤 Top 20 Database Interview Questions

### 🔰 Basics & Architecture
1. **Explain the difference between SQL and NoSQL databases.**
   - *Answer:* SQL (Relational) uses a fixed schema and is optimized for complex queries and consistency (ACID). NoSQL (Non-relational) is schema-less, optimized for horizontal scaling and speed (BASE).
2. **What are the ACID properties?**
   - *Answer:* **Atomicity** (all or nothing), **Consistency** (valid state), **Isolation** (concurrent tx don't interfere), **Durability** (persisted even on failure).
3. **What is a "Managed Service" for databases (e.g., RDS)?**
   - *Answer:* a cloud service where the provider handles heavy lifting like OS maintenance, patching, backups, and high availability.
4. **What is a "Database Migration"?**
   - *Answer:* The process of moving data from one database to another or upgrading the schema while maintaining data integrity.
5. **How do you handle backups for a production database?**
   - *Answer:* Implement automated snapshots, point-in-time recovery (PITR), and cross-region backups for disaster recovery.

### ⚙️ Performance & Scaling
6. **What is "Horizontal vs Vertical Scaling" for databases?**
   - *Answer:* **Vertical** means adding more CPU/RAM to a single server. **Horizontal** (Sharding/Replication) means adding more servers to handle the load.
7. **Explain "Read Replicas" and "Multi-AZ".**
   - *Answer:* **Read Replicas** are used to offload read-heavy traffic (scaling). **Multi-AZ** is for high availability and automatic failover in case of a zone failure.
8. **What is a "Slow Query" and how do you find it?**
   - *Answer:* A query that takes longer than a threshold. Find it using slow query logs (MySQL) or `pg_stat_statements` (PostgreSQL) and optimize using **Indexes**.
9. **When should you use Redis or ElastiCache?**
   - *Answer:* For high-speed caching of frequently accessed data (like sessions or leaderboard data) to reduce load on the primary database.
10. **What is "Connection Pooling"?**
    - *Answer:* Maintaining a cache of database connections so that they can be reused when future requests to the database are required, reducing the overhead of opening new connections.

### 🚀 Advanced Ops & Security
11. **Explain "Blue-Green" deployment for databases.**
    - *Answer:* Running two identical DB environments. You upgrade the passive one and then cut over. It's much riskier than app-level BG because of data synchronization.
12. **How do you secure a database in AWS?**
    - *Answer:* Place it in a private subnet, use Security Groups to restrict access to only the App tier, enable encryption at rest/transit, and use IAM for database authentication.
13. **What is "Database Drift"?**
    - *Answer:* When the actual schema in production differs from the schema defined in your source control or migration scripts.
14. **What is "CDC" (Change Data Capture)?**
    - *Answer:* A set of design patterns that determine and track the data that has changed so that action can be taken using the changed data (often for real-time analytics).
15. **How do you handle a database that is Out of Space?**
    - *Answer:* Increase the volume size (if cloud), implement data archiving/purging, or clean up large unused logs.
16. **Explain "Primary vs Secondary" in MongoDB.**
    - *Answer:* The Primary receives all write operations. Secondaries replicate the primary's logs and can be used for read operations or failover.
17. **What is "Sharding"?**
    - *Answer:* A type of horizontal scaling that involves splitting a large database into smaller, more manageable pieces called "shards" across multiple servers.
18. **What is "Vacuuming" in PostgreSQL?**
    - *Answer:* Reclaiming storage occupied by "dead" rows (deleted or updated) to maintain performance.
19. **How do you prevent SQL Injection?**
    - *Answer:* Use prepared statements, parameterized queries, and input validation.
20. **What is "Technical Debt" in databases?**
    - *Answer:* Legacy schemas, missing indexes, or lack of proper backup/versioning that makes it harder to maintain or scale the system.

---

## 🧠 Database Knowledge Quiz

**1. Which property ensures that even if a server crashes, the data stays saved?**
- A) Atomicity
- B) Consistency
- C) Isolation
- D) Durability
*Answer: D*

**2. Which database is NOT a NoSQL database?**
- A) MongoDB
- B) Redis
- C) PostgreSQL
- D) DynamoDB
*Answer: C*

**3. What is the primary purpose of a "Read Replica"?**
- A) To provide high availability (failover)
- B) To scale read-heavy traffic
- C) To backup data
- D) To run complex SQL joins
*Answer: B*

**4. Where should a production database be placed?**
- A) Public Subnet
- B) Private Subnet
- C) Anywhere with a password
- D) Localhost only
*Answer: B*

**5. Which protocol is primarily used for database communication over a network?**
- A) HTTP
- B) FTP
- C) TCP
- D) UDP
*Answer: C*

**6. What does "Indexing" do for a database?**
- A) It makes writes faster
- B) It makes reads (searches) faster
- C) It encrypts the data
- D) It deletes duplicates
*Answer: B*

**7. "Point-in-Time Recovery" (PITR) allows you to:**
- A) Speed up the CPU
- B) Restore the database to any specific second in the past
- C) Backup only the index
- D) Predict future data
*Answer: B*

**8. Which tool is used to monitor AWS RDS performance?**
- A) CloudWatch
- B) S3
- C) IAM
- D) VPC
*Answer: A*

**9. In a "Multi-AZ" RDS deployment, the secondary instance is:**
- A) Used for read traffic
- B) Used for write traffic
- C) A passive standby for failover
- D) A different database engine
*Answer: C*

**10. "Eventually Consistent" is a hallmark of which consistency model?**
- A) ACID
- B) BASE
- C) JSON
- D) CRUD
*Answer: B*

**11. Which SQL command is used to remove all records from a table without deleting the table structure?**
- A) DELETE
- B) DROP
- C) TRUNCATE
- D) REMOVE
*Answer: C*

**12. What is a "Foreign Key"?**
- A) A password for an external user
- B) A column that links to a primary key in another table
- C) A key for encrypting data
- D) A temporary table
*Answer: B*

**13. Which NoSQL type is Redis?**
- A) Document Store
- B) Column Family
- C) Key-Value
- D) Graph
*Answer: C*

**14. What is the standard port for MySQL?**
- A) 5432
- B) 3306
- C) 8080
- D) 27017
*Answer: B*

**15. What is the standard port for PostgreSQL?**
- A) 3306
- B) 5432
- C) 6379
- D) 80
*Answer: B*

**16. "OOMKilled" on a database container usually means:**
- A) Out of Disk
- B) Out of Memory
- C) Out of Network
- D) System Update
*Answer: B*

**17. Which component handles database connection sharing?**
- A) Proxy
- B) Switch
- C) Load Balancer
- D) Connection Pooler
*Answer: D*

**18. What is a "Database Snapshot"?**
- A) A photo of the server
- B) A point-in-time backup of the entire database
- C) A list of all table names
- D) A performance report
*Answer: B*

**19. CRUD stands for:**
- A) Create, Read, Update, Delete
- B) Copy, Rename, Undo, Deploy
- C) Clear, Reset, Upload, Download
- D) Correct, Run, Use, Debug
*Answer: A*

**20. In an e-commerce app, where should the 'Cart' data ideally be stored for high frequency?**
- A) S3
- B) Cold HDD
- C) Redis/ElastiCache
- D) GitHub
*Answer: C*

---

## ✅ Knowledge Check
- [x] Passed the 20-Question Quiz
- [x] Reviewed the Top 20 Interview Questions
- [x] Understand SQL vs NoSQL differences
