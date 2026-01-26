# Database Fundamentals Challenges 💾

Master the core operational tasks for managing production databases.

---

## 🏆 Challenge 01: The Backup Strategist
**Objective**: Implement an automated logical backup routine.

1.  **Scenario**: A production database needs a daily backup.
2.  **Task**: Write a Shell or Python script that:
    *   Generates a timestamped `.sql` dump.
    *   Compresses the dump (`gzip`).
    *   Moves the backup to a `/backups/db-name/` directory.
3.  **Command**: Research the `pg_dump` (for Postgres) or `mysqldump` (for MySQL) flags.
4.  **Verification**: Restore the backup to a test database instance and verify the data integrity.

---

## 🏆 Challenge 02: Performance Audit
**Objective**: Identify slow-running queries that are strangling your app.

1.  **Requirement**: Enable Query Logging in your database configuration (`postgresql.conf` or `my.cnf`).
2.  **Task**: 
    *   Set the `long_query_time` to 2 seconds.
    *   Generate simulate a slow query (e.g., a cross-join on a large table).
3.  **Discovery**: Find the slow query in the logs.
4.  **Optimization**: Research the `EXPLAIN` command and draft a basic plan to add an index to a column used in a `WHERE` clause.

---

## 🏆 Challenge 03: User Permission Lockdown (RBAC)
**Objective**: Implement the Principle of Least Privilege for database users.

1.  **Task**: Create three distinct users for a shared database:
    *   `readonly_user`: Can only select from specific tables.
    *   `app_user`: Can SELECT, INSERT, UPDATE on application tables.
    *   `admin_user`: Full control (the "Boss").
2.  **Logic**: Draft the SQL `GRANT` and `REVOKE` statements required.
3.  **Security Question**: Why should your web application NEVER connect using the `root` or `postgres` superuser?

---

## 📁 Solutions
Standard SQL schemas and backup scripts are in the `Boilerplates/` directory.
