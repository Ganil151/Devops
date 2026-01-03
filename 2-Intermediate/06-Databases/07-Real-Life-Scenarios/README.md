# Database Real-Life Scenarios

See how database expertise solves production-level performance, migration, and disaster recovery issues.

---

## 🛠️ Scenario 1: Zero-Downtime Migration to the Cloud
**Problem:** Your company is moving from a self-hosted MySQL server in an on-prem data center to **Amazon RDS**. You cannot afford more than 5 minutes of downtime for the 500GB database.

**The Solution:**
1. Use **AWS DMS (Database Migration Service)**.
2. Step 1: Perform a Full Load of the data to RDS.
3. Step 2: Use **CDC (Change Data Capture)** to keep the new RDS instance in sync with the on-prem DB in real-time.
4. Step 3: Once the lag is near zero, point the application to the new RDS endpoint and shut down the on-prem DB.
**Goal**: Migrate without interrupting the business.

---

## 🏗️ Scenario 2: The "Death by a Thousand Updates"
**Problem:** Your PostgreSQL database CPU is hovering at 99%. Users are reporting extremely slow page loads.

**The Investigation:**
1. Run `EXPLAIN ANALYZE` on the most frequent queries.
2. You find that a huge `products` table is being scanned entirely because a search column doesn't have an **Index**.
3. **The Fix**: Create a Concurrent Index on the searched column. This allows reads/writes to continue while the index is being built.
**Goal**: Identify and resolve database bottlenecks via indexing.

---

## 🌩️ Scenario 3: Recovering from a "Fat Finger" Error
**Problem:** A junior developer accidentally ran `DELETE FROM users` instead of a specific user ID on the production database.

**The Solution:**
1. Do NOT panic.
2. Use **Point-in-Time Recovery (PITR)** on your RDS snapshots.
3. Select the snapshot from 5 minutes *before* the accidental deletion.
4. Launch a new DB instance from that point.
5. Export the lost data and import it back into the primary database, or point the app to the newly restored instance.
**Goal**: Use automation to survive human error.

---

## 🔄 Scenario 4: Scaling for "Black Friday" Traffic
**Problem:** Your relational database is struggling to handle the sudden 10x spike in traffic. Writes are fine, but "Product Detailed View" (Read traffic) is timing out.

**The Solution:**
1. Add 3 **Read Replicas** in different Availability Zones.
2. Update the application configuration to split traffic:
   - Send all `INSERT/UPDATE/DELETE` to the **Primary** endpoint.
   - Send all `SELECT` queries to the **Reader** endpoint (Load Balanced).
**Goal**: Use horizontal scaling to handle mass traffic.

---

## 🛡️ Scenario 5: Managing Database Credentials Safely
**Problem:** You find that the database password is plain text in a `config.php` file in the Git repository.

**The Solution:**
1. Immediately change the database password.
2. Integrate **AWS Secrets Manager** or **HashiCorp Vault**.
3. Update the application to pull the password dynamically using an IAM role or token at runtime.
4. Use a `.gitignore` to ensure configuration files are never committed again.
**Goal**: Implement "Secretless" architecture for database security.

---

## 💡 Key Takeaway
Database management in DevOps is about **Risk Mitigation**. A good DevOps engineer ensures that data is always available, always secure, and always recoverable, no matter what happens to the underlying infrastructure.
