# Database Interview Questions & Quiz

Master the art of managing data at scale and prepare for technical DevOps and SRE interviews.

---

## 🎤 Top 20 Database Interview Questions

<b>1. </b>
<details>
<summary>Show Answer</summary>
Answer: * SQL (Relational) uses a fixed schema and is optimized for complex queries and consistency (ACID). NoSQL (Non-relational) is schema-less, optimized for horizontal scaling and speed (BASE).
</details>


<b>2. </b>
<details>
<summary>Show Answer</summary>
Answer: * **Atomicity** (all or nothing), **Consistency** (valid state), **Isolation** (concurrent tx don't interfere), **Durability** (persisted even on failure).
</details>


<b>3. </b>
<details>
<summary>Show Answer</summary>
Answer: * a cloud service where the provider handles heavy lifting like OS maintenance, patching, backups, and high availability.
</details>


<b>4. </b>
<details>
<summary>Show Answer</summary>
Answer: * The process of moving data from one database to another or upgrading the schema while maintaining data integrity.
</details>


<b>5. </b>
<details>
<summary>Show Answer</summary>
Answer: * Implement automated snapshots, point-in-time recovery (PITR), and cross-region backups for disaster recovery.
</details>


<b>6. </b>
<details>
<summary>Show Answer</summary>
Answer: * **Vertical** means adding more CPU/RAM to a single server. **Horizontal** (Sharding/Replication) means adding more servers to handle the load.
</details>


<b>7. </b>
<details>
<summary>Show Answer</summary>
Answer: * **Read Replicas** are used to offload read-heavy traffic (scaling). **Multi-AZ** is for high availability and automatic failover in case of a zone failure.
</details>


<b>8. </b>
<details>
<summary>Show Answer</summary>
Answer: * A query that takes longer than a threshold. Find it using slow query logs (MySQL) or `pg_stat_statements` (PostgreSQL) and optimize using **Indexes**.
</details>


<b>9. </b>
<details>
<summary>Show Answer</summary>
Answer: * For high-speed caching of frequently accessed data (like sessions or leaderboard data) to reduce load on the primary database.
</details>


<b>10. </b>
<details>
<summary>Show Answer</summary>
Answer: * Maintaining a cache of database connections so that they can be reused when future requests to the database are required, reducing the overhead of opening new connections.
</details>


<b>11. </b>
<details>
<summary>Show Answer</summary>
Answer: * Running two identical DB environments. You upgrade the passive one and then cut over. It's much riskier than app-level BG because of data synchronization.
</details>


<b>12. </b>
<details>
<summary>Show Answer</summary>
Answer: * Place it in a private subnet, use Security Groups to restrict access to only the App tier, enable encryption at rest/transit, and use IAM for database authentication.
</details>


<b>13. </b>
<details>
<summary>Show Answer</summary>
Answer: * When the actual schema in production differs from the schema defined in your source control or migration scripts.
</details>


<b>14. </b>
<details>
<summary>Show Answer</summary>
Answer: * A set of design patterns that determine and track the data that has changed so that action can be taken using the changed data (often for real-time analytics).
</details>


<b>15. </b>
<details>
<summary>Show Answer</summary>
Answer: * Increase the volume size (if cloud), implement data archiving/purging, or clean up large unused logs.
</details>


<b>16. </b>
<details>
<summary>Show Answer</summary>
Answer: * The Primary receives all write operations. Secondaries replicate the primary's logs and can be used for read operations or failover.
</details>


<b>17. </b>
<details>
<summary>Show Answer</summary>
Answer: * A type of horizontal scaling that involves splitting a large database into smaller, more manageable pieces called "shards" across multiple servers.
</details>


<b>18. </b>
<details>
<summary>Show Answer</summary>
Answer: * Reclaiming storage occupied by "dead" rows (deleted or updated) to maintain performance.
</details>


<b>19. </b>
<details>
<summary>Show Answer</summary>
Answer: * Use prepared statements, parameterized queries, and input validation.
</details>


<b>20. </b>
<details>
<summary>Show Answer</summary>
Answer: * Legacy schemas, missing indexes, or lack of proper backup/versioning that makes it harder to maintain or scale the system.
</details>


---

## 🧠 Database Knowledge Quiz

<b>1. Which property ensures that even if a server crashes, the data stays saved?</b>
<details>
<summary>Show Answer</summary>
Answer: D
</details>


<b>2. Which database is NOT a NoSQL database?</b>
<details>
<summary>Show Answer</summary>
Answer: C
</details>


<b>3. What is the primary purpose of a "Read Replica"?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>4. Where should a production database be placed?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>5. Which protocol is primarily used for database communication over a network?</b>
<details>
<summary>Show Answer</summary>
Answer: C
</details>


<b>6. What does "Indexing" do for a database?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>7. "Point-in-Time Recovery" (PITR) allows you to:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>8. Which tool is used to monitor AWS RDS performance?</b>
<details>
<summary>Show Answer</summary>
Answer: A
</details>


<b>9. In a "Multi-AZ" RDS deployment, the secondary instance is:</b>
<details>
<summary>Show Answer</summary>
Answer: C
</details>


<b>10. "Eventually Consistent" is a hallmark of which consistency model?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>11. Which SQL command is used to remove all records from a table without deleting the table structure?</b>
<details>
<summary>Show Answer</summary>
Answer: C
</details>


<b>12. What is a "Foreign Key"?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>13. Which NoSQL type is Redis?</b>
<details>
<summary>Show Answer</summary>
Answer: C
</details>


<b>14. What is the standard port for MySQL?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>15. What is the standard port for PostgreSQL?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>16. "OOMKilled" on a database container usually means:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>17. Which component handles database connection sharing?</b>
<details>
<summary>Show Answer</summary>
Answer: D
</details>


<b>18. What is a "Database Snapshot"?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>19. CRUD stands for:</b>
<details>
<summary>Show Answer</summary>
Answer: A
</details>


<b>20. In an e-commerce app, where should the 'Cart' data ideally be stored for high frequency?</b>
<details>
<summary>Show Answer</summary>
Answer: C
</details>


---

## ✅ Knowledge Check
- [x] Passed the 20-Question Quiz
- [x] Reviewed the Top 20 Interview Questions
- [x] Understand SQL vs NoSQL differences