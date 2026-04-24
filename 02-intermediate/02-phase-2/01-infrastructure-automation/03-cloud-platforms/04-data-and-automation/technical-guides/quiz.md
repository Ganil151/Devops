# 🧠 Knowledge Check: Cloud Data & Compliance

### 1. Why is data considered "stateful" in cloud architecture?
- A) It is always stored in the United States (State).
- B) It holds unique information that cannot be identically reproduced if lost.
- C) It only exists while the server is running.
- D) It changes its state from liquid to gas.

### 2. Which S3 feature requires a hardware MFA device to permanently delete an object version?
- A) Versioning
- B) Object Locking
- C) MFA Delete
- D) Intelligent-Tiering

### 3. What is the primary purpose of a "Read Replica" in a relational database?
- A) To increase high availability and failover speed.
- B) To offload read-heavy workloads and improve performance at scale.
- C) To store backups in a cold tier.
- D) To encrypt the data.

### 4. An RPO (Recovery Point Objective) of 15 minutes means:
- A) The system must be back online within 15 minutes of a crash.
- B) We can tolerate losing at most 15 minutes of data.
- C) We must back up the data every 15 days.
- D) The user session expires after 15 minutes.

### 5. Which storage class is best for data that is rarely accessed but must be available immediately (milliseconds) when requested?
- A) S3 Standard
- B) S3 Standard-Infrequent Access (IA)
- C) S3 Glacier Flexible Retrieval
- D) S3 Glacier Deep Archive

### 6. What does "WORM" stand for in the context of Object Locking?
- A) Worldwide Object Resource Management
- B) Write Once Read Many
- C) Weekly Origin Replica Maintenance
- D) Web Optimized Resource Model

### 7. Which AWS service is best for monitoring API calls and resource changes for audit purposes?
- A) CloudWatch
- B) CloudTrail
- C) AWS Config
- D) Trusted Advisor

### 8. What is "Eventual Consistency"?
- A) A promise that data will eventually be deleted.
- B) A model where data updates might take a few seconds to propagate to all nodes in a distributed system.
- C) A database that never fails.
- D) A model where data is always strong and never changes.

### 9. Which FinOps practice provides the most immediate cost savings for long-term backups?
- A) Moving snapshots to a "Cold" or "Archive" storage tier.
- B) Increasing the frequency of backups.
- C) Using the most expensive instance type for the database.
- D) Turning off encryption.

### 10. In a "Multi-AZ" RDS deployment, is the replica in the second zone used for read traffic by default?
- A) Yes, it acts as a read replica.
- B) No, it is a "Synchronous Standby" used only for failover and does not support traffic until promoted.
- C) Only if you use Aurora.
- D) Only on weekends.

---

## 🔑 Answer Key
1. **B** (Databases and storage are stateful; compute is usually stateless).
2. **C** (Prevents accidental or malicious permanent deletion).
3. **B** (Scaling reads horizontally).
4. **B** (Maximum acceptable data loss).
5. **B** (IA provides millisecond access but lower storage price).
6. **B** (Ensures data once written cannot be overwritten or deleted).
7. **B** (CloudTrail logs the "Who, What, When" of API actions).
8. **B** (Common in S3 and NoSQL systems).
9. **A** (Archive storage is significantly cheaper than warm storage).
10. **B** (Multi-AZ is for HA, not for read scaling).
