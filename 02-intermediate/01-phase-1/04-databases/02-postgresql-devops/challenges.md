# PostgreSQL DevOps Challenges 🐘

Master the maintenance and reliability of the world's most advanced relational database.

---

## 🏆 Challenge 01: WAL Log Management
**Objective**: Understand the "Write-Ahead Log" for point-in-time recovery.

1.  **Requirement**: Research the `archive_mode` and `archive_command` in `postgresql.conf`.
2.  **Task**: Configure Postgres to archive its WAL files to a secondary disk drive.
3.  **Simulation**: Intentionally delete a row from a table at 10:00 AM.
4.  **Goal**: Explain the steps needed to restore the database to 9:59 AM using your archived logs.

---

## 🏆 Challenge 02: The Vacuum Cleaner
**Objective**: Prevent "Bloat" in high-transaction environments.

1.  **Scenario**: Your DB size is growing rapidly, but the number of records is staying the same.
2.  **Requirement**: Identify "Dead Tuples" in a specific table.
3.  **Task**: Run a `VACUUM ANALYZE` on the bloated table.
4.  **Security Question**: What is the difference between `VACUUM` and `VACUUM FULL` in terms of production uptime? (Research: Locking).

---

## 🏆 Challenge 03: Connection Pooling
**Objective**: Handle thousands of concurrent users without crashing the DB.

1.  **Requirement**: Install **PgBouncer**.
2.  **Task**: Configure PgBouncer to sit between your application and Postgres.
3.  **Observation**: Compare the performance of 100 direct connections vs. 100 pooled connections.
4.  **Discovery**: Identify the three different pooling modes (Session, Transaction, Statement) and recommend one for a typical REST API.

---

## 📁 Solutions
PgBouncer configuration files and VACUUM maintenance scripts are in the `Boilerplates/` directory.
