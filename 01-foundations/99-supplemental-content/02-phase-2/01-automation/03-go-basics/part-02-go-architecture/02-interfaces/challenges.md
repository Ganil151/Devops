# Interfaces - DevOps Challenges

## Challenge 1: Multi-Cloud Storage Interface
**Scenario**: Create abstraction for S3, Azure Blob, GCS.

**Requirements:**
1. Define `CloudStorage` interface with: `Upload(filename string) error`, `Download(filename string) error`
2. Implement for at least 2 cloud providers (simulated)
3. Create function that accepts interface and works with any provider

**Verification:**
```bash
go run cloud-storage.go
# Expected: Uploads to both S3 and Azure using same code
```

---

## Challenge 2: Notification System
**Scenario**: Send alerts via Email, Slack, or PagerDuty.

**Requirements:**
1. Define `Notifier` interface with `Send(message string) error`
2. Implement for 3 notification channels
3. Create `AlertManager` that sends to multiple notifiers

**Verification:**
```bash
go run notifier.go "Database connection failed"
# Expected: Sends alert via all 3 channels
```

---

## Challenge 3: Database Connection Pool
**Scenario**: Abstract database operations for PostgreSQL/MySQL.

**Requirements:**
1. Define `Database` interface with: `Query(sql string)`, `Close()`
2. Implement for 2 database types
3. Create `RunMigrations(db Database)` function

**Verification:**
```bash
go run db-pool.go
# Expected: Runs migrations on both DB types
```
